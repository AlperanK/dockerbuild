FROM ubuntu:20.04
ENV DEBIAN_FRONTEND noninteractive
RUN ln -fs /usr/share/zoneinfo/Europe/Istanbul /etc/localtime
# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        tzdata \
        ca-certificates \
        apt-transport-https \
        ca-certificates \
        git \
        iputils-ping \
        libcurl4 \
        libicu66 \
        libssl1.0 \
        libunwind8 \
        netcat \
        unzip \
        gss-ntlmssp \
        wget \
        vim

# Install Docker
RUN curl -fsSL https://get.docker.com -o get-docker.sh && \
    sh get-docker.sh

# Install kubectl
RUN KUBECTL_VERSION=$(wget -qO- https://dl.k8s.io/release/stable.txt) && \
    wget -O /usr/local/bin/kubectl "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" && \
    chmod +x /usr/local/bin/kubectl

# Install Azure DevOps agent
ARG AZP_AGENT_VERSION=3.224.0
RUN wget https://vstsagentpackage.azureedge.net/agent/${AZP_AGENT_VERSION}/vsts-agent-linux-x64-${AZP_AGENT_VERSION}.tar.gz && \
    mkdir -p /azp && \
    tar -zxvf vsts-agent-linux-x64-${AZP_AGENT_VERSION}.tar.gz -C /azp && \
    rm -rf vsts-agent-linux-x64-${AZP_AGENT_VERSION}.tar.gz

# Add a user to run the agent
RUN useradd -m -U -s /bin/bash azp

# Change permissions of the /azp directory
RUN chown -R azp:azp /azp

# Set the working directory
WORKDIR /azp

# Copy the start script
COPY start.sh .
RUN chmod +x start.sh

# Set the user
USER azp

# Run the start script
CMD ["./start.sh"]
