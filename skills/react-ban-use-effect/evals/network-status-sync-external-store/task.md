# Network Awareness Hook

## Problem/Feature Description

Your team is building a React application that needs to display a "You are offline" banner whenever the user loses their internet connection, and hide it again when connectivity returns. A product engineer has asked you to create a reusable custom React hook — `useNetworkStatus` — that any component in the app can import to know whether the browser currently has network access. The hook must be reactive: the consuming component should re-render automatically when the network state changes, without the component itself managing subscriptions or cleanup.

The codebase follows a strict policy of keeping React components declarative. The team has had problems in the past with effects being misused for things that have cleaner declarative solutions, so there is a preference for reaching for the right React primitive rather than defaulting to a `useState` + manual subscription pattern. When the right primitive is genuinely unavailable, engineers are expected to either use an approved shared wrapper or leave a written explanation of why a lower-level approach is necessary.

## Output Specification

Produce the following files in your working directory:

- `src/hooks/useNetworkStatus.ts` (or `.js`) — the custom hook implementation
- `src/components/NetworkBanner.tsx` (or `.jsx`) — a small demo component that uses the hook to conditionally render an offline notice
- `README.md` — a short explanation (a few sentences to a paragraph) of why you chose the implementation approach you did, including the React primitive(s) you used and why they are the right fit for this problem

Do not generate any build artifacts, bundled output, or files larger than a few kilobytes. The source files are what will be reviewed.
