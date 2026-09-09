# Advanced RAG Assistant

A **Hybrid Retrieval-Augmented Generation (RAG) Assistant** that combines **Vector Search + BM25 + Cross-Encoder Reranking** to answer questions from user-uploaded documents.

The application uses a **persistent ChromaDB knowledge base**, so documents are embedded once during ingestion and reused for future queries.

The application is **Dockerized and deployed on AWS EC2** with a Streamlit interface.

---

## ✨ Features

* 🔍 **Hybrid Retrieval** — Vector Search + BM25
* 🎯 **Cross-Encoder Reranking** — improves relevance of retrieved chunks
* 💾 **Persistent Knowledge Base** — ChromaDB stores embeddings and metadata
* ⚡ **One-Time Ingestion** — documents are not re-embedded for every query
* 🛡️ **Duplicate Detection** — SHA-256 based document deduplication
* 🧠 **Query Rewriting** — converts follow-up questions into standalone queries
* 💬 **Conversation Memory** — uses recent chat history for contextual answers
* 📚 **Source Citations** — responses include document/page references
* 📊 **Retrieval Observability** — retrieval, reranking and generation latency
* 🗑️ **Document Management** — add and delete documents
* 📝 **Application Logging**
* ☁️ **AWS EC2 Deployment**
* 🐳 **Dockerized Application**

---

# 🏗️ Architecture

```text
                         User
                          │
                          ▼
                   ┌─────────────┐
                   │  Streamlit  │
                   │     UI      │
                   └──────┬──────┘
                          │
              ┌───────────┴───────────┐
              │                       │
              ▼                       ▼
        Document Ingestion        Query Pipeline
              │                       │
              ▼                       ▼
        Load & Chunk             Query Rewriting
              │                       │
              ▼                       ▼
        SHA-256 Hash          ┌────────┴────────┐
              │               │                 │
              ▼               ▼                 ▼
       Duplicate Check     Vector Search      BM25
              │               │                 │
              ▼               └────────┬────────┘
        Embeddings                     │
              │                        ▼
              ▼                 Hybrid Retrieval
          ChromaDB                     │
              │                        ▼
              │                Cross-Encoder
              │                  Reranking
              │                        │
              │                        ▼
              │                 Relevant Context
              │                        │
              │                        ▼
              │                 Answer Generator
              │                        │
              └────────────────────────┤
                                       ▼
                              Answer + Citations
```

---

# 🔄 RAG Pipeline

### Document Ingestion

```text
Document
   ↓
Load
   ↓
Chunk
   ↓
SHA-256 Hash
   ↓
Duplicate Check
   ↓
Generate Embeddings
   ↓
Store in ChromaDB
   ↓
Save Metadata
```

Documents are embedded **only during ingestion**.

### Query Pipeline

```text
User Question
      ↓
Conversation History
      ↓
Query Rewriter
      ↓
Vector Search + BM25
      ↓
Hybrid Retrieval
      ↓
Cross-Encoder Reranking
      ↓
Top Relevant Chunks
      ↓
LLM
      ↓
Answer + Sources
```

---

# 🔎 Hybrid Retrieval

The system combines two retrieval strategies:

| Retrieval         | Purpose                 |
| ----------------- | ----------------------- |
| **Vector Search** | Semantic similarity     |
| **BM25**          | Exact keyword matching  |
| **Cross-Encoder** | Final relevance ranking |

Using both Vector Search and BM25 helps the system handle both **semantic queries and exact technical keywords**.

---

# 💾 Persistent Knowledge Base

The knowledge base is stored inside:

```text
chroma_db/
```

It contains:

* ChromaDB vector data
* `manifest.json`

The `uploads/` directory is only used as temporary storage during ingestion.

```text
uploads/
   ↓
Temporary

chroma_db/
   ↓
Persistent Knowledge Base
```

This allows uploaded documents and their embeddings to remain available across future queries and application restarts.

---

# 🛡️ Document Deduplication

Each document is processed using a **SHA-256 hash**.

```text
Document
   ↓
SHA-256
   ↓
manifest.json
   ↓
Already Exists?
   ├── Yes → Skip
   └── No  → Ingest
```

This prevents duplicate documents and unnecessary embedding computation.

---

# 📚 Citations & Metadata

Each chunk stores metadata such as:

```text
filename
page
upload_date
file_type
```

This metadata is used for:

* Source citations
* Document deletion
* Source tracking
* Duplicate management

---

# 🧠 Conversational RAG

The assistant supports follow-up questions using recent conversation history.

Example:

```text
User: What is RAG?

User: What are its advantages?

User: How does it reduce hallucination?
```

The query rewriting component uses the conversation context to convert ambiguous follow-up questions into meaningful standalone search queries.

---

# 📊 Retrieval Observability

Each response can expose retrieval information such as:

```text
Rewritten Query
Retrieved Chunks
Retrieval Scores
Reranking Scores
Retrieval Latency
Reranking Latency
Generation Latency
```

Application logs are maintained in:

```text
logs/app.log
```

---

# 📁 Project Structure

```text
Rag-Trial/
│
├── app.py
├── agents.py
├── config.py
├── ingestion.py
├── pipeline.py
├── prompts.py
├── tools.py
│
├── requirements.txt
├── pyproject.toml
├── uv.lock
├── .python-version
├── .gitignore
│
├── chroma_db/
│   └── manifest.json
│
├── uploads/
│
└── logs/
    └── app.log
```

| File           | Responsibility                                 |
| -------------- | ---------------------------------------------- |
| `app.py`       | Streamlit UI                                   |
| `config.py`    | Models, paths and configuration                |
| `tools.py`     | Loaders, chunking, retrieval and reranking     |
| `ingestion.py` | Hashing, deduplication and document management |
| `prompts.py`   | RAG prompts                                    |
| `agents.py`    | Query rewriting and answer-generation chains   |
| `pipeline.py`  | Ingestion and query entry points               |

---

# 🛠️ Tech Stack

**Language**

* Python

**GenAI / LLM**

* LangChain
* LCEL
* LLM-based Query Rewriting
* LLM-based Answer Generation

**Retrieval**

* ChromaDB
* Vector Search
* BM25
* Hybrid Retrieval
* Cross-Encoder Reranking

**NLP**

* Sentence Transformers
* Embedding Models
* Cross-Encoder Models

**Frontend**

* Streamlit

**Deployment**

* Docker
* AWS EC2

**Monitoring**

* Python Logging
* Latency Tracking

---

# ☁️ AWS EC2 Deployment

The application is deployed on an **AWS EC2 Ubuntu instance** using Docker.

### Deployment Flow

```text
Source Code
    ↓
Docker Build
    ↓
Docker Image
    ↓
AWS EC2
    ↓
Docker Container
    ↓
Streamlit
    ↓
RAG Assistant
```

The Streamlit application runs on port:

```text
8501
```

The deployment supports the complete workflow:

```text
Document Upload
      ↓
Ingestion
      ↓
Persistent ChromaDB
      ↓
Hybrid Retrieval
      ↓
Reranking
      ↓
LLM Generation
      ↓
Cited Answer
```

### Persistent Storage

ChromaDB is maintained separately from the temporary upload directory so that the knowledge base can persist across application/container restarts.

---

# ⚙️ Installation

Clone the repository:

```bash
git clone https://github.com/Swainakash0799/Rag-Trial.git
cd Rag-Trial
```

Install dependencies:

using `uv`:

```bash
uv sync
```
### Windows

```bash
.venv\Scripts\activate
```

# 🔑 Environment Variables

Create a `.env` file:

```env
GROQ_API_KEY=your_api_key
```

Add other API keys required by your configured models.

**Never commit API keys or `.env` files to GitHub.**

---

# ▶️ Run Locally

```bash
streamlit run app.py
```

Open the Streamlit URL shown in the terminal.

---

# 📖 Usage

### 1. Build Knowledge Base

Go to **Knowledge Base** → Upload a document.

The document is:

```text
Loaded → Chunked → Embedded → Stored
```

### 2. Ask Questions

Go to **Ask** and ask questions about your uploaded documents.

### 3. Follow Up

Continue asking questions naturally using conversation context.

### 4. View Sources

Inspect the source document and page associated with the generated answer.

---

# 🎯 Key Engineering Highlights

This project demonstrates practical implementation of:

* Retrieval-Augmented Generation
* Hybrid Search
* Vector Databases
* BM25 Retrieval
* Cross-Encoder Reranking
* Query Rewriting
* Conversational RAG
* Persistent Knowledge Bases
* Document Deduplication
* Metadata-Based Citations
* LangChain LCEL
* Dockerization
* AWS EC2 Deployment
* Application Logging

---

# 🚀 Future Improvements

* Streaming responses
* Authentication
* Multi-user knowledge bases
* RAG evaluation framework
* Retrieval metrics
* Hallucination detection
* Query routing
* Multi-query retrieval
* HTTPS + custom domain
* CI/CD with GitHub Actions

---

# 👨‍💻 Author

**Akash Swain**

---

## ⭐ Project Summary

**Advanced RAG Assistant** is an end-to-end GenAI application that combines **Hybrid Retrieval, Cross-Encoder Reranking, Query Rewriting, Conversation Memory, Persistent ChromaDB, and Source Citations**, packaged with Docker and deployed on **AWS EC2**.
