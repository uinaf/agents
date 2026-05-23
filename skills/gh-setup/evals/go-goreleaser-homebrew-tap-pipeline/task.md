# Automate Binary Releases for a Go CLI Tool

## Problem/Feature Description

Redwood Systems ships `vaultctl`, a Go command-line tool for secrets rotation used by their infrastructure teams. The project has grown from an internal tool to one adopted by a handful of partner companies, and the team wants to provide polished distribution: pre-built binaries for Linux/macOS/Windows, a Homebrew formula so Mac users can simply `brew install`, and signed build attestation for supply-chain compliance.

Currently releases are manually created by whoever remembers to cut one — no consistency in changelog, no binary builds, and the Homebrew formula in the separate tap repository under the `redwood-systems` GitHub organization is months out of date. The team wants the release process fully automated: commits following conventional commits on `main` should automatically determine the version, create a GitHub Release, build cross-platform binaries, and update the Homebrew tap formula. No human should need to run anything.

The cross-repo Homebrew update needs its own authentication token since the default GitHub token only covers the source repo. The team is also conscious of supply-chain security and wants build provenance attestation for the release artifacts.

## Output Specification

Produce the following files:

- `.github/workflows/ci.yml` — complete GitHub Actions workflow with verify and release jobs
- `.releaserc.json` — semantic-release configuration
- `.goreleaser.yaml` — GoReleaser configuration including Homebrew tap automation

Include a brief `SETUP.md` at the repo root documenting which secrets need to be configured in repo settings and what permissions the TAP_GITHUB_TOKEN requires.

## Input Files

The following files represent the current repository state. Extract them before beginning.

=============== FILE: go.mod ===============
module github.com/redwood-systems/vaultctl

go 1.22
=============== END FILE ===============

=============== FILE: Makefile ===============
.PHONY: verify build

verify:
	go vet ./...
	go test ./...
	golangci-lint run

build:
	go build -o bin/vaultctl ./cmd/vaultctl
=============== END FILE ===============
