"""
FastAPI application for Kubernetes deployment across multiple cloud providers.
"""
import os
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional
import logging

# Configure logging
logging.basicConfig(level=os.getenv("LOG_LEVEL", "INFO"))
logger = logging.getLogger(__name__)

app = FastAPI(
    title="FastAPI K8s App",
    description="FastAPI application deployed via Kubernetes with GitOps",
    version="1.0.0"
)

# Enable CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


class HealthResponse(BaseModel):
    """Health check response model"""
    status: str
    environment: str
    cloud_provider: Optional[str] = None
    version: str


class DataItem(BaseModel):
    """Data item model"""
    id: int
    name: str
    description: Optional[str] = None


@app.get("/health", response_model=HealthResponse)
async def health_check():
    """
    Health check endpoint for Kubernetes liveness/readiness probes
    """
    return HealthResponse(
        status="healthy",
        environment=os.getenv("ENVIRONMENT", "development"),
        cloud_provider=os.getenv("CLOUD_PROVIDER", "unknown"),
        version="1.0.0"
    )


@app.get("/readiness", response_model=HealthResponse)
async def readiness_check():
    """
    Readiness check endpoint for Kubernetes readiness probe
    """
    return HealthResponse(
        status="ready",
        environment=os.getenv("ENVIRONMENT", "development"),
        cloud_provider=os.getenv("CLOUD_PROVIDER", "unknown"),
        version="1.0.0"
    )


@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "message": "FastAPI Kubernetes Application",
        "docs": "/docs",
        "openapi_schema": "/openapi.json"
    }


@app.get("/api/v1/info")
async def app_info():
    """Get application information"""
    return {
        "app_name": "FastAPI K8s App",
        "environment": os.getenv("ENVIRONMENT", "development"),
        "cloud_provider": os.getenv("CLOUD_PROVIDER", "unknown"),
        "version": "1.0.0",
        "features": {
            "kubernetes": True,
            "gitops": True,
            "multi_cloud": True
        }
    }


@app.get("/api/v1/data/{item_id}")
async def get_data(item_id: int):
    """Get data item by ID"""
    if item_id < 0:
        raise HTTPException(status_code=400, detail="Item ID must be positive")
    return {
        "id": item_id,
        "name": f"Item {item_id}",
        "description": "Sample data item from Kubernetes"
    }


@app.post("/api/v1/data")
async def create_data(item: DataItem):
    """Create new data item"""
    logger.info(f"Creating data item: {item.name}")
    return {
        "id": 1,
        "name": item.name,
        "description": item.description,
        "created": True
    }


@app.get("/metrics")
async def metrics():
    """Metrics endpoint for Prometheus"""
    return {
        "app_name": "fastapi-k8s-app",
        "version": "1.0.0",
        "status": "running"
    }


if __name__ == "__main__":
    import uvicorn
    port = int(os.getenv("PORT", 8000))
    uvicorn.run(
        app,
        host="0.0.0.0",
        port=port,
        log_level=os.getenv("LOG_LEVEL", "info").lower()
    )
