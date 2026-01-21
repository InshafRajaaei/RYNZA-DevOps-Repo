# CI/CD Assignment Documentation

## Part 1: CI/CD Design Diagram

### Diagram Architecture Overview

The CI/CD pipeline for the RYNZA E-Commerce application should include the following components and flow:

```
┌─────────────────────────────────────────────────────────────────────┐
│                         GIT REPOSITORY                              │
│                      (GitHub/GitLab/Bitbucket)                      │
│  - Frontend Code (React + Vite)                                     │
│  - Admin Panel Code (React + Vite)                                  │
│  - Backend Code (Node.js + Express)                                 │
│  - Docker & Docker-Compose files                                    │
│  - Infrastructure as Code (IaC)                                     │
└────────────────────────┬────────────────────────────────────────────┘
                         │ (Webhook Trigger)
                         ↓
         ┌───────────────────────────────┐
         │       CI/CD TOOL: JENKINS     │
         │   (or GitHub Actions/GitLab CI)│
         ├───────────────────────────────┤
         │ Pipeline Stages:              │
         │ 1. Code Checkout              │
         │ 2. Build                      │
         │ 3. Test                       │
         │ 4. Code Quality Analysis      │
         │ 5. Docker Image Build         │
         │ 6. Push to Registry           │
         └───────────┬───────────────────┘
                     │
        ┌────────────┴─────────────┐
        ↓                          ↓
   ┌─────────────┐         ┌──────────────┐
   │ Docker      │         │ Container    │
   │ Registry    │         │ Registry     │
   │ (DockerHub/ │         │ (ECR/Harbor) │
   │  Artifactory)         └──────────────┘
   └────────┬────┘
            │
            ↓
    ┌──────────────────────────────────┐
    │  IaC TOOLS                       │
    │  - Terraform (Infrastructure)    │
    │  - Ansible (Configuration Mgmt)  │
    └───────────┬──────────────────────┘
                │
    ┌───────────┴──────────────────────────┐
    │    DEPLOYMENT ENVIRONMENT            │
    │   (Development/Staging/Production)   │
    │                                      │
    │   Cloud Platform (AWS/Azure/GCP)    │
    │   or On-Premises Infrastructure     │
    │                                      │
    │  ┌──────────────────────────────┐   │
    │  │ CONTAINER ORCHESTRATION      │   │
    │  │ (Docker Compose / Kubernetes)│   │
    │  │                              │   │
    │  │ ┌──────────────────────────┐ │   │
    │  │ │  Frontend Container      │ │   │
    │  │ │  (React App - Port 3000) │ │   │
    │  │ │  - Served by Nginx       │ │   │
    │  │ └──────────┬───────────────┘ │   │
    │  │            │ (HTTP/HTTPS)    │   │
    │  │ ┌──────────↓───────────────┐ │   │
    │  │ │  Admin Panel Container   │ │   │
    │  │ │  (React App - Port 3001) │ │   │
    │  │ │  - Served by Nginx       │ │   │
    │  │ └──────────┬───────────────┘ │   │
    │  │            │ (HTTP/HTTPS)    │   │
    │  │ ┌──────────↓───────────────┐ │   │
    │  │ │  Backend Container       │ │   │
    │  │ │  (Node.js - Port 4000)   │ │   │
    │  │ │  - Express API Server    │ │   │
    │  │ │  - RESTful Endpoints     │ │   │
    │  │ └──────────┬───────────────┘ │   │
    │  │            │ (Internal API)  │   │
    │  │ ┌──────────↓───────────────┐ │   │
    │  │ │  MongoDB Container       │ │   │
    │  │ │  (Database - Port 27017) │ │   │
    │  │ │  - Persistent Storage    │ │   │
    │  │ │  - RYNZAdb database      │ │   │
    │  │ └──────────────────────────┘ │   │
    │  │                              │   │
    │  │  All containers connected    │   │
    │  │  via 'ecommerce-network'     │   │
    │  │  bridge network             │   │
    │  └──────────────────────────────┘   │
    │                                      │
    │  Volumes:                            │
    │  - mongodb_data (Persistent storage) │
    │                                      │
    └──────────────────────────────────────┘
            ↓
    ┌──────────────────────────────┐
    │   MONITORING & LOGGING       │
    │  - ELK Stack / Prometheus    │
    │  - Application Logs          │
    │  - Container Metrics         │
    └──────────────────────────────┘
```

### Component Connectivity Details

**1. Git Repository → Jenkins:**
- Webhook triggers Jenkins pipeline on code push/merge
- Jenkins checks out source code from Git

**2. Jenkins Pipeline Flow:**
- **Stage 1 - Code Checkout:** Clone repository
- **Stage 2 - Build:** 
  - Backend: `npm install`, build
  - Frontend: `npm install`, `npm run build` (Vite)
  - Admin Panel: `npm install`, `npm run build` (Vite)
- **Stage 3 - Test:**
  - Run Jest tests for all applications
  - Code coverage analysis
- **Stage 4 - Code Quality:**
  - SonarQube analysis
  - Dependency vulnerability scanning
- **Stage 5 - Docker Build:**
  - Build Docker images for each service
- **Stage 6 - Push to Registry:**
  - Push images to Docker Hub/ECR with version tags

**3. IaC Tools (Terraform & Ansible):**
- **Terraform:** Provisions cloud infrastructure (VMs, networks, security groups)
- **Ansible:** Configures deployed servers, installs Docker/Docker Compose, manages configurations

**4. Deployment Environment:**
- Docker Compose orchestrates containers on target environment
- All services connected via Docker network bridge
- Database volume persists data

**5. Inter-Container Connectivity:**
- **Frontend (3000) ↔ Backend (4000):** HTTP requests via Docker network
- **Backend (4000) ↔ MongoDB (27017):** Internal database queries
- **Frontend & Admin Panel:** Share same network for potential future microservice communication

---

## Part 2: Automation Approach

### DevOps Tools & Technologies

| Tool | Version | Purpose |
|------|---------|---------|
| **Git** | (Latest) | Version control, source code management |
| **Jenkins** | 2.414+ | CI/CD orchestration, pipeline automation |
| **Docker** | 24.0+ | Containerization of applications |
| **Docker Compose** | 2.20+ | Multi-container orchestration (Dev/Staging) |
| **Kubernetes** | 1.28+ | Production container orchestration (optional) |
| **Terraform** | 1.6+ | Infrastructure as Code for cloud resources |
| **Ansible** | 2.15+ | Configuration management and server automation |
| **SonarQube** | 10.0+ | Code quality and security analysis |
| **Docker Hub / ECR** | Latest | Container image registry |
| **Nginx** | 1.25+ | Reverse proxy and web server (in containers) |

### Application Tools & Dependencies

#### Backend (Node.js)
| Dependency | Version | Purpose |
|------------|---------|---------|
| Node.js | 18+ | Runtime environment |
| Express | 5.1.0 | Web framework and REST API |
| Mongoose | 8.19.3 | MongoDB object modeling |
| JWT (jsonwebtoken) | 9.0.2 | Authentication token generation |
| Bcrypt | 6.0.0 | Password encryption |
| Dotenv | 17.2.3 | Environment variable management |
| Multer | 2.0.2 | File upload handling |
| Cloudinary | 2.8.0 | Cloud image storage and management |
| Stripe | 18.5.0 | Payment processing |
| CORS | 2.8.5 | Cross-Origin Resource Sharing |
| Nodemon | 3.1.10 | Development auto-reload |

#### Frontend (React + Vite)
| Dependency | Version | Purpose |
|------------|---------|---------|
| React | 18.2.0-18.3.1 | UI library |
| React DOM | 18.2.0-18.3.1 | DOM rendering |
| React Router DOM | 7.9.5 | Client-side routing |
| Vite | 5.0.0-5.4.21 | Fast build tool and dev server |
| Axios | 1.13.2 | HTTP client for API calls |
| TailwindCSS | 3.4.0-3.4.18 | Utility-first CSS framework |
| React Toastify | 11.0.5 | Toast notifications |
| PostCSS | 8.4.0-8.5.6 | CSS processing |
| Autoprefixer | 10.4.0-10.4.21 | CSS vendor prefixing |
| Jest | 30.1.3 | Testing framework |

#### Database
| Component | Version | Purpose |
|-----------|---------|---------|
| MongoDB | 6.0+ | NoSQL database for data storage |
| Docker (MongoDB Image) | mongo:6 | Containerized database service |

### Deployment Automation Strategy

#### Pipeline Stages Explained

**Stage 1: Code Checkout**
```
Action: Git pull from repository
Trigger: Push/Merge to main branch
Output: Source code ready for building
```

**Stage 2: Build**
```
Backend:
  - npm install (install dependencies)
  - npm run build (transpile if needed)

Frontend/Admin Panel:
  - npm install (install dependencies)
  - npm run build (Vite builds production assets)

Output: Built applications ready for containerization
```

**Stage 3: Testing**
```
Backend:
  - Jest unit tests
  - Integration tests with mongodb-memory-server
  - Code coverage reporting

Frontend/Admin Panel:
  - Jest unit tests with jsdom
  - React component tests with @testing-library

Output: Test reports and coverage metrics
Pass/Fail decision point
```

**Stage 4: Code Quality Analysis**
```
- SonarQube static code analysis
- Security vulnerability scanning (SAST)
- Dependency check for known vulnerabilities
- Code style linting (ESLint)

Output: Quality gates passed/failed
```

**Stage 5: Docker Image Build**
```
Build Dockerfiles for:
  1. Backend (Node.js runtime with Express server)
  2. Frontend (Nginx serving React build)
  3. Admin Panel (Nginx serving React build)

Tagging: registry.com/app-name:build-number
         registry.com/app-name:latest

Output: Docker images ready for registry
```

**Stage 6: Push to Container Registry**
```
Push images to:
  - Docker Hub (public/private repos)
  - AWS ECR / Azure ACR (cloud registries)

Actions:
  - Apply semantic versioning tags
  - Scan images for vulnerabilities
  - Generate image manifests

Output: Images available for deployment
```

**Stage 7: Deploy to Target Environment**
```
Development/Staging:
  - Use Terraform to provision infrastructure
  - Use Ansible to configure deployment servers
  - Deploy using Docker Compose
  - Health checks and smoke tests

Production:
  - Blue-Green deployment strategy
  - Gradual rollout with monitoring
  - Automatic rollback on failure

Output: Application live and accessible
```

**Stage 8: Post-Deployment**
```
- Run integration tests
- Verify external APIs (Stripe, Cloudinary)
- Monitor application logs
- Health checks (frontend/backend availability)
- Database connectivity verification

Output: Deployment success/failure notification
```

### Automation Workflow Summary

1. **Developer pushes code** → Git repository
2. **Webhook triggers** → Jenkins pipeline starts
3. **Automated testing & build** → Code quality validated
4. **Docker images created** → Containerization
5. **Images pushed** → Container registry
6. **Infrastructure provisioned** → Terraform scripts
7. **Servers configured** → Ansible playbooks
8. **Containers deployed** → Docker Compose on target
9. **Monitoring activated** → Logs and metrics collected
10. **Notifications sent** → Deployment status to team

### Key Benefits of This Automation

- **Speed:** Reduced deployment time from hours to minutes
- **Reliability:** Consistent deployments with automated testing
- **Scalability:** Easy to add new services or scale existing ones
- **Safety:** Automated rollback on failures
- **Visibility:** Comprehensive logging and monitoring
- **Compliance:** Automated security scanning and code quality checks

### Environment Variables Management

- **Development:** Store in docker-compose.yml
- **Staging/Production:** Use secrets management (AWS Secrets Manager, HashiCorp Vault)
- **Jenkins:** Use Jenkins Credentials plugin for sensitive data
- **Ansible:** Use Ansible Vault for encrypted variables

### Monitoring & Observability

- **Application Logs:** Centralized logging (ELK Stack, CloudWatch)
- **Container Metrics:** Prometheus for resource monitoring
- **APM Tools:** Datadog, New Relic for application performance
- **Alerting:** PagerDuty/Slack notifications for critical issues

