# Configure the Kubernetes provider to connect to the EKS cluster

provider "kubernetes" {
  host                   = aws_eks_cluster.nti_eks.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.nti_eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.nti_eks.token
}

#eks cluster and node group configuration
resource "aws_iam_role" "eks_cluster_role" {
  name = "nti-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

#iam role for worker nodes

resource "aws_iam_role" "eks_node_role" {
  name = "nti-eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach necessary policies to the node role
resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "ec2_registry_access" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}


 #ُُEKS cluster
resource "aws_eks_cluster" "nti_eks" {
  name     = "nti-eks-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = "1.31"

  vpc_config {
    subnet_ids = [
      aws_subnet.private-us-east-2a.id,
      aws_subnet.private-us-east-2b.id
    ]
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]
}

data "aws_eks_cluster_auth" "nti_eks" {
  name = aws_eks_cluster.nti_eks.name
}


# node_group
resource "aws_eks_node_group" "nti_nodes" {
  cluster_name    = aws_eks_cluster.nti_eks.name
  node_group_name = "nti-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = [
    aws_subnet.private-us-east-2a.id,
    aws_subnet.private-us-east-2b.id
  ]
  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 2
  }

  instance_types = ["t3.small"]  # ← غيرت من t3.medium

  depends_on = [
    aws_eks_cluster.nti_eks,
    aws_iam_role_policy_attachment.eks_worker_node_policy
  ]
}
