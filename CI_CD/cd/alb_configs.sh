#!/bin/bash
################################################################################
# Script Name:    alb_configs.sh
# Description:    Prepares ALB and service account for the cluster
#
# Author:         Godbless Biekro
# Date Created:   2024-12-19
# Last Modified:  2024-12-19
# Version:        1.1.0
# Notes:          Requires sudo privileges. Tested on Ubuntu 22.04 LTS.
################################################################################

set -e  # Exit on any error

# Variables
clusterName="projectX-eks"
region="us-east-1"

# Validate tools
for tool in aws eksctl kubectl helm; do
  if ! command -v $tool &> /dev/null; then
    echo "Error: $tool is not installed. Please install it before running this script."
    exit 1
  fi
done

# Fetch AWS account ID and EKS VPC ID
aws_account_id=$(aws sts get-caller-identity --query "Account" --output text)
eks_vpc_id=$(aws eks describe-cluster --name "${clusterName}" --query "cluster.resourcesVpcConfig.vpcId" --output text)


# IAM Policy for ALB Controller
curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.11.0/docs/install/iam_policy.json
aws iam create-policy --policy-name AWSLoadBalancerControllerIAMPolicy --policy-document file://iam_policy.json

# Create a service account
eksctl create iamserviceaccount \
--cluster="${clusterName}" \
--namespace=kube-system \
--name=aws-load-balancer-controller \
--role-name=AmazonEKSLoadBalancerControllerRole \
--attach-policy-arn=arn:aws:iam::${aws_account_id}:policy/AWSLoadBalancerControllerIAMPolicy \
--approve

# Deploy the controller with Helm
helm repo add eks https://aws.github.io/eks-charts
helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system \
--set clusterName="${clusterName}" \
--set serviceAccount.create=false \
--set serviceAccount.name=aws-load-balancer-controller \
--set region="${region}" \
--set vpcId="${eks_vpc_id}"


echo "ALB setup completed successfully."

#Installing ArgoCD using the installation manifest file
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
