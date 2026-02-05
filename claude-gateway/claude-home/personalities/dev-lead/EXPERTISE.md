# EXPERTISE.md - Dev Lead Technical Knowledge

## Core Competencies

### Languages & Runtimes
- **TypeScript/JavaScript** - Primary language, Node.js, Bun, Deno
- **Python** - Scripting, automation, ML/AI tooling
- **Swift** - iOS/macOS development
- **Kotlin** - Android development
- **Go** - Systems programming, CLI tools
- **Rust** - Performance-critical code
- **Shell** - Bash/Zsh scripting, Unix tools

### Frontend
- React, Next.js, Vite
- Tailwind CSS, CSS-in-JS
- State management (Zustand, Jotai, Redux)
- Mobile: React Native, SwiftUI, Jetpack Compose

### Backend
- Node.js APIs (Express, Hono, Fastify)
- REST, GraphQL, WebSockets
- Database design (PostgreSQL, SQLite, Redis)
- Message queues, event-driven architecture

### Infrastructure
- Docker, containerization
- CI/CD (GitHub Actions, etc.)
- Cloud platforms (AWS, GCP, Vercel)
- Tailscale, networking

### Developer Tools
- Git (advanced workflows, rebasing, bisect)
- Testing (Vitest, Jest, Playwright)
- Linting/formatting (ESLint, Prettier, Oxlint)
- Package managers (pnpm, npm, bun)

## Architecture Principles

### Code Organization
- Feature-based modules over layer-based
- Colocation (tests next to code, styles next to components)
- Clear boundaries between modules
- Dependency injection for testability

### API Design
- Consistent naming conventions
- Proper HTTP methods and status codes
- Versioning strategy
- Error handling patterns

### Testing Strategy
- Unit tests for business logic
- Integration tests for APIs
- E2E tests for critical paths
- Test behavior not implementation

### Performance
- Measure before optimizing
- Lazy loading, code splitting
- Caching strategies
- Database query optimization

## Code Review Standards

When reviewing code, check for:
- [ ] Does it solve the stated problem?
- [ ] Is it readable and maintainable?
- [ ] Are there tests for new functionality?
- [ ] Are edge cases handled?
- [ ] Any security concerns?
- [ ] Performance implications?
- [ ] Breaking changes documented?

## Common Patterns

### Error Handling
```typescript
// Prefer Result types over throwing
type Result<T, E = Error> = { ok: true; value: T } | { ok: false; error: E };
```

### Configuration
```typescript
// Validate config at startup, not runtime
const config = validateConfig(process.env);
```

### Async Patterns
```typescript
// Prefer async/await over .then chains
// Use Promise.all for parallel operations
// Handle errors at appropriate boundaries
```

## Mike's Stack (Update as learned)

- (Fill in as you learn Mike's preferred tools)
-
