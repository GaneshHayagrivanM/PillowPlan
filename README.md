# Monthly Task Tracker

Monorepo for a production-ready, containerized full-stack app to define recurring tasks monthly, track daily completion, and visualize statistics. Deployable on Google Kubernetes Engine (GKE).

## Structure
- backend/ (Spring Boot 3, Java 21, Maven)
- frontend/ (React 18 + TypeScript + Vite)
- db/migrations/ (Flyway SQL)
- infra/
  - docker/ (Dockerfiles)
  - k8s/ (Deployments, Services, Ingress, ConfigMaps, Secrets, PVCs)
- docker-compose.yml (local development)

## High-level Features
- JWT auth, timezone-aware scheduling
- Recurrence: daily, weekly, monthly
- Today view; mark complete/incomplete with notes
- Statistics: completion rate, heatmap, streaks, trends
- PostgreSQL with UTC timestamps; Flyway migrations
- Dockerized services; Kubernetes manifests for GKE

## Development
- Backend: Spring Boot 3 + JPA + Validation + Security + OpenAPI
- Frontend: React + TS + React Query + MUI + Recharts + Heatmap
- Tests: JUnit/Mockito/Testcontainers; target ≥80% coverage

## Next Steps (PR plan)
1. Scaffold repo (this PR)
2. Backend auth + core models + Flyway baseline
3. Recurrence utilities and /tasks/today endpoint
4. Frontend auth + Today view MVP
5. Task CRUD + monthly planner UI
6. Stats endpoints + dashboard UI
7. Dockerize + docker-compose for local dev
8. GKE manifests & deployment wiring
9. Tests to ≥80% and perf checks
10. Docs and polish (accessibility, themes)
