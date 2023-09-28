# Use a specific tag for determinism
FROM ubuntu:20.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies, kubectl, Java, and Azure DevOps agent
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        ca-certificates \
        git \
        iputils-ping \
        libcurl4 \
        libicu66 \
        libssl1.0 \
        libunwind8 \
        netcat \
        unzip \
        wget \
        vim \
        openjdk-8-jdk && \
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    chmod +x kubectl && \
    mv kubectl /usr/local/bin/ && \
    ARG AZP_AGENT_VERSION=3.224.0 && \
    wget https://vstsagentpackage.azureedge.net/agent/${AZP_AGENT_VERSION}/vsts-agent-linux-x64-${AZP_AGENT_VERSION}.tar.gz && \
    mkdir -p /azp && \
    tar -zxvf vsts-agent-linux-x64-${AZP_AGENT_VERSION}.tar.gz -C /azp && \
    rm -rf vsts-agent-linux-x64-${AZP_AGENT_VERSION}.tar.gz && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    useradd -m -U -s /bin/bash azp && \
    chown -R azp:azp /azp

# Set the working directory
WORKDIR /azp

# Copy the start script
COPY start.sh .
RUN chmod +x start.sh

# Set the user
USER azp

# Run the start script
CMD ["./start.sh"]
