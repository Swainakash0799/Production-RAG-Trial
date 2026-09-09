# ☁️ AWS EC2 Deployment

The **RAG-Trial** is deployed on an **AWS EC2 Ubuntu instance** using Docker. The deployment separates the application environment from the local development environment and provides a reproducible way to run the RAG system in the cloud.

## Deployment Architecture

```text
                         GitHub Repository
                                │
                                ▼
                         GitHub Actions
                                │
                         Build Docker Image
                                │
                                ▼
                            Docker Hub
                                │
                                ▼
                         AWS EC2 Instance
                                │
                         Pull Docker Image
                                │
                                ▼
                      Run Docker Container
                                │
                                ▼
                         Streamlit :8501
                                │
                                ▼
                    Advanced RAG Assistant
                                │
              ┌─────────────────┴─────────────────┐
              │                                   │
              ▼                                   ▼
        ChromaDB Knowledge Base              LLM APIs
        Persistent Storage                 Embeddings / Reranker
```

---

# 🚀 Deployment Workflow

The application follows this deployment pipeline:

```text
1. Develop application locally
        ↓
2. Push code to GitHub
        ↓
3. GitHub Actions starts CI/CD
        ↓
4. Build Docker image
        ↓
5. Push Docker image to Docker Hub
        ↓
6. Connect to AWS EC2
        ↓
7. Pull latest Docker image
        ↓
8. Stop/remove previous container
        ↓
9. Start new container
        ↓
10. Application available on port 8501
```

This allows new application versions to be deployed without manually setting up the Python environment each time.

---

# 🐳 Docker Configuration

The application is containerized using Docker.

A typical Docker workflow is:

```bash
docker build -t advanced-rag-assistant .
```

Run locally:

```bash
docker run -p 8501:8501 advanced-rag-assistant
```

The Streamlit application runs inside the container and exposes port:

```text
8501
```

---

# ☁️ AWS EC2 Setup

## 1. Create an EC2 Instance

Create an Ubuntu-based EC2 instance from the AWS Console.

Recommended configuration depends on the model and workload being used.

For CPU-based deployment, ensure the instance has sufficient:

* RAM
* CPU
* Disk space

The Cross-Encoder and embedding models can require significant memory during startup.

---

# 🔐 2. Configure Security Group

Allow inbound traffic for the Streamlit application.

```text
Type: Custom TCP
Port: 8501
Source: Your IP / Required network range
```

For public access, the application can be accessed using:

```text
http://<EC2-PUBLIC-IP>:8501
```

> For production use, HTTPS through a reverse proxy such as Nginx and a domain name is recommended instead of exposing Streamlit directly.

---

# 🐳 3. Install Docker on EC2

Connect to the EC2 instance through SSH and install Docker.

```bash
sudo apt-get update -y
```

Install Docker:

```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
```

Allow the Ubuntu user to run Docker:

```bash
sudo usermod -aG docker ubuntu
```

Apply the group change:

```bash
newgrp docker
```

Verify:

```bash
docker --version
```

---

# 📦 4. Pull and Run the Docker Image

After the image is pushed to Docker Hub:

```bash
docker pull <dockerhub-username>/advanced-rag-assistant:latest
```

Run the container:

```bash
docker run -d \
  --name rag-trial \
  -p 8501:8501 \
  --env-file .env \
  <dockerhub-username>/rag-trial:latest
```

Check the running container:

```bash
docker ps
```

View logs:

```bash
docker logs rag-trial
```

---

# 🔄 5. Updating the Deployment

When new changes are pushed to GitHub:

```text
GitHub
   ↓
GitHub Actions
   ↓
Build New Docker Image
   ↓
Push to Docker Hub
   ↓
EC2
   ↓
Pull Latest Image
   ↓
Restart Container
```

The EC2 instance therefore runs the latest application version without requiring manual Python package installation.

---

# ⚙️ GitHub Actions CI/CD

The project can use **GitHub Actions** to automate the Docker build and deployment workflow.

Example pipeline:

```text
Git Push
   ↓
GitHub Actions
   ↓
Checkout Repository
   ↓
Build Docker Image
   ↓
Login to Docker Hub
   ↓
Push Image
   ↓
Deploy to EC2
   ↓
Restart Container
```

A typical workflow file is:

```text
.github/
└── workflows/
    └── deploy.yml
```

---

# 🔑 GitHub Actions Secrets

Sensitive credentials should **never be hard-coded** in the repository.

Configure them under:

```text
GitHub Repository
        ↓
Settings
        ↓
Secrets and variables
        ↓
Actions
```

Typical secrets include:

```text
DOCKER_USERNAME
DOCKER_PASSWORD

AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_REGION

LLM_API_KEY
```

If your application uses specific providers, add only the keys actually required by your configuration.

For example:

```text
GROQ_API_KEY
TAVILY_API_KEY
OPENAI_API_KEY
```

> Do not commit `.env`, API keys, AWS credentials, Docker Hub passwords, or access tokens to GitHub.

---

# 🔐 Environment Variable Management

The application reads credentials through environment variables.

Example:

```env
GROQ_API_KEY=your_api_key
```

The `.env` file should remain local/private and should be included in `.gitignore`.

```text
.env
*.env
```

For CI/CD deployment, secrets should be injected through GitHub Actions or the EC2 environment rather than stored inside the Docker image.

---

# 💾 Persistent ChromaDB Storage

Because the RAG application maintains a persistent knowledge base, ChromaDB data should not be treated as disposable container data.

The deployment can mount a persistent directory:

```bash
docker run -d \
  --name advanced-rag-assistant \
  -p 8501:8501 \
  -v /home/ubuntu/chroma_db:/app/chroma_db \
  --env-file .env \
  <dockerhub-username>/advanced-rag-assistant:latest
```

This provides:

```text
EC2 Host
   │
   └── /home/ubuntu/chroma_db
             │
             ▼
       Docker Container
             │
             └── /app/chroma_db
```

Therefore, restarting or replacing the container does not automatically remove the persistent knowledge base.

### Important

Before deploying with this approach, make sure the application's configured ChromaDB path is:

```text
/app/chroma_db
```

and that the Docker volume is mounted to the same path.

---

# 🩺 Deployment Verification

After deployment, verify the container:

```bash
docker ps
```

Check application logs:

```bash
docker logs advanced-rag-assistant
```

Test the Streamlit application:

```text
http://<EC2-PUBLIC-IP>:8501
```

Then verify the complete workflow:

```text
✓ Application loads
✓ Document upload works
✓ Document ingestion works
✓ ChromaDB persists
✓ Duplicate detection works
✓ Hybrid retrieval works
✓ Reranking works
✓ LLM response works
✓ Citations are displayed
```

---

# 📊 Production-Oriented Deployment

The deployment demonstrates an end-to-end workflow:

```text
                 DEVELOPMENT
                      │
                      ▼
                   GitHub
                      │
                      ▼
                CI/CD Pipeline
                      │
                      ▼
                 Docker Image
                      │
                      ▼
                 Docker Hub
                      │
                      ▼
                  AWS EC2
                      │
                      ▼
              Docker Container
                      │
             ┌────────┴────────┐
             │                 │
             ▼                 ▼
         Streamlit         ChromaDB
             │             Persistent
             ▼              Storage
        RAG Pipeline
             │
       ┌─────┴─────┐
       ▼           ▼
    Retrieval     LLM
```

This provides a reproducible deployment workflow from source code to a cloud-hosted AI application.

---

# 🛡️ Security Considerations

The deployment follows basic security practices:

* API keys stored as environment variables
* Secrets managed through GitHub Actions Secrets
* `.env` excluded from version control
* AWS credentials never committed to the repository
* Docker images built from the project source
* EC2 Security Group controls network access
* Persistent application data separated from temporary uploads

For a production environment, additional improvements would include:

* HTTPS
* Reverse proxy
* Domain name
* Authentication
* IAM roles instead of long-lived AWS access keys
* HTTPS/TLS termination
* Monitoring and alerting
* Automated backups for the knowledge base

---

# 📌 Deployment Summary

```text
GitHub
  ↓
GitHub Actions
  ↓
Docker Build
  ↓
Docker Hub
  ↓
AWS EC2
  ↓
Docker Container
  ↓
Streamlit
  ↓
Advanced RAG Assistant
```

The result is an **end-to-end cloud-deployed GenAI application** that combines advanced retrieval techniques with containerization, persistent storage, and automated deployment.
