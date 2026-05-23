# Review: Payment Retry Logic Changes

## Problem/Feature Description

A fintech startup's engineering team has opened a pull request that modifies the payment retry scheduler. The change adds exponential backoff, extends retry count from 3 to 5 attempts, and introduces a new `PaymentStatus.PENDING_RETRY` state into the state machine. The team lead is concerned: this code path processes real money, and a subtle bug here could double-charge customers or silently drop failed payments.

The lead wants a thorough, evidence-backed review before this goes to their staging environment. They've explicitly asked for someone to dig into the error handling paths and understand whether failures will surface properly in logs and monitoring — not just whether the logic looks right at a glance.

## Output Specification

Write the review to `review-report.md`. Make sure the report is complete enough for the team lead to make a deployment decision without needing to ask follow-up questions.

## Input Files

The following files are provided as inputs. Extract them before beginning.

=============== FILE: repo/CLAUDE.md ===============
# Repo Guidelines

- All payment state transitions must be logged at INFO level with payment ID and old/new state.
- Retries must not exceed 5 attempts; enforce this as a constant, not a magic number.
- External payment provider errors must be classified before retrying: transient (retry) vs permanent (fail fast).
- Dead-letter any payment that exhausts retries; do not silently drop.

=============== FILE: repo/src/payments/retry.ts ===============
import { db } from '../db';
import { chargeProvider } from '../providers/payment';
import { logger } from '../logger';

const MAX_RETRIES = 5;

export async function scheduleRetry(paymentId: string) {
  const payment = await db.payments.findById(paymentId);
  if (!payment) return;

  if (payment.retryCount >= MAX_RETRIES) {
    await db.payments.update(paymentId, { status: 'dead_lettered' });
    logger.info('Payment dead-lettered', { paymentId, retryCount: payment.retryCount });
    return;
  }

  const delay = Math.pow(2, payment.retryCount) * 1000;
  await sleep(delay);

  try {
    await chargeProvider.charge(payment);
    await db.payments.update(paymentId, { status: 'succeeded', retryCount: payment.retryCount + 1 });
    logger.info('Payment succeeded on retry', { paymentId });
  } catch (err: any) {
    await db.payments.update(paymentId, {
      status: 'PENDING_RETRY',
      retryCount: payment.retryCount + 1,
    });
    logger.warn('Retry failed', { paymentId });
  }
}

function sleep(ms: number) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

=============== FILE: repo/src/payments/retry.old.ts ===============
// DEPRECATED: replaced by retry.ts. Do not use.
export async function legacyRetry(paymentId: string) {
  // old fixed-interval retry, 3 attempts
  for (let i = 0; i < 3; i++) {
    try {
      // charge logic was here
      return;
    } catch {
      // ignore and try again
    }
  }
}

=============== FILE: repo/tests/retry.test.ts ===============
import { scheduleRetry } from '../src/payments/retry';

jest.mock('../src/db');
jest.mock('../src/providers/payment');
jest.mock('../src/logger');

test('schedules retry for failed payment', async () => {
  const mockDb = require('../src/db').db;
  mockDb.payments.findById.mockResolvedValue({ id: 'p1', retryCount: 0, status: 'failed' });
  mockDb.payments.update.mockResolvedValue({});
  const mockCharge = require('../src/providers/payment').chargeProvider;
  mockCharge.charge.mockRejectedValue(new Error('timeout'));

  await scheduleRetry('p1');

  expect(mockDb.payments.update).toHaveBeenCalledWith('p1', expect.objectContaining({ status: 'PENDING_RETRY' }));
});

test('dead-letters after max retries', async () => {
  const mockDb = require('../src/db').db;
  mockDb.payments.findById.mockResolvedValue({ id: 'p2', retryCount: 5, status: 'PENDING_RETRY' });
  mockDb.payments.update.mockResolvedValue({});

  await scheduleRetry('p2');

  expect(mockDb.payments.update).toHaveBeenCalledWith('p2', expect.objectContaining({ status: 'dead_lettered' }));
});
