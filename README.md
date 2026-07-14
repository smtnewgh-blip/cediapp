# CEDI App - Cedi Coin Platform

A full-stack application for CEDI coin management with Claude AI and Manus integration for intelligent transaction processing and financial analysis.

## Features
- Real-time transaction management
- Claude AI-powered financial insights
- Manus integration for workflow automation
- RESTful API backend
- React-based frontend
- Docker containerization
- CI/CD deployment pipeline

## Quick Start

### Prerequisites
- Node.js 18+
- Python 3.10+
- Docker & Docker Compose
- Claude API Key
- Manus API credentials

### Backend Setup
```bash
cd backend
npm install
cp .env.example .env
# Add your Claude and Manus API keys to .env
npm run dev
```

### Frontend Setup
```bash
cd frontend
npm install
npm run dev
```

### Docker Deployment
```bash
docker-compose up -d
```

## Project Structure
```
cediapp/
├── frontend/          # React application
├── backend/           # Node.js/Express API
├── docker-compose.yml # Container orchestration
├── .github/          # GitHub Actions CI/CD
└── docs/             # Documentation
```

## API Documentation
See `docs/API.md` for detailed API endpoints.

## Contributing
Please read CONTRIBUTING.md before submitting PRs.

## License
MIT
