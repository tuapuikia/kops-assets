## Setup vars

KUBERNETES_VERSION=$1
KOPS_VERSION=$2
ASSET_BUCKET="some-asset-bucket"
ASSET_PREFIX=""

# Please note that this filename of cni asset may change with kubernetes version
# Find this in https://github.com/kubernetes/kops/blob/master/upup/pkg/fi/cloudup/networking.go
CNI_FILENAME=cni-plugins-amd64-v0.7.5.tgz
CNI_VERSION=0.8.7
NEW_CNI_FILENAME=v$CNI_VERSION/cni-plugins-linux-amd64-v$CNI_VERSION.tgz
CONTAINERD_VERSION=1.4.4

export KOPS_BASE_URL=https://s3.cn-north-1.amazonaws.com.cn/$ASSET_BUCKET/kops/$KOPS_VERSION/
export CNI_VERSION_URL=https://s3.cn-north-1.amazonaws.com.cn/$ASSET_BUCKET/kubernetes/network-plugins/$CNI_FILENAME
export CNI_ASSET_HASH_STRING=d595d3ded6499a64e8dac02466e2f5f2ce257c9f
export CONTAINERD_CNI=cri-containerd-cni-$CONTAINERD_VERSION-linux-amd64.tar.gz

## Create kops-assets directory
if [ ! -d ./kops-assets ]; then
	mkdir -p ./kops-assets
	cd kops-assets
else
	echo "kops-assets directory already exists"
	cd kops-assets
fi

## Download assets

KUBERNETES_ASSETS=(
  network-plugins/$CNI_FILENAME
  release/$KUBERNETES_VERSION/bin/linux/amd64/kube-apiserver.tar
  release/$KUBERNETES_VERSION/bin/linux/amd64/kube-controller-manager.tar
  release/$KUBERNETES_VERSION/bin/linux/amd64/kube-proxy.tar
  release/$KUBERNETES_VERSION/bin/linux/amd64/kube-scheduler.tar
  release/$KUBERNETES_VERSION/bin/linux/amd64/kubectl
  release/$KUBERNETES_VERSION/bin/linux/amd64/kubelet
  release/$KUBERNETES_VERSION/bin/linux/arm64/kube-apiserver.tar
  release/$KUBERNETES_VERSION/bin/linux/arm64/kube-controller-manager.tar
  release/$KUBERNETES_VERSION/bin/linux/arm64/kube-proxy.tar
  release/$KUBERNETES_VERSION/bin/linux/arm64/kube-scheduler.tar
  release/$KUBERNETES_VERSION/bin/linux/arm64/kubectl
  release/$KUBERNETES_VERSION/bin/linux/arm64/kubelet
)
for asset in "${KUBERNETES_ASSETS[@]}"; do
  dir="kubernetes-release/$(dirname "$asset")"
  mkdir -p "$dir"
  url="https://storage.googleapis.com/kubernetes-release/$asset"
  wget -N -P "$dir" "$url"
  [ "${asset##*.}" != "gz" ] && wget -P "$dir" "$url.sha256" || wget -P "$dir" "$url.sha1"
  [ "${asset##*.}" == "tar" ] && wget -P "$dir" "${url%.tar}.docker_tag"
done

CONTAINERD_CNI_ASSETS=(
  $CONTAINERD_CNI
)
for asset in "${CONTAINERD_CNI_ASSETS[@]}"; do
  dir="containerd/containerd/releases/download/v$CONTAINERD_VERSION/$(dirname "$asset")"
  mkdir -p "$dir"
  url="https://github.com/containerd/containerd/releases/download/v$CONTAINERD_VERSION/$asset"
  wget -N -P "$dir" "$url"
  [ "${asset##*.}" != "gz" ] && wget -P "$dir" "$url.sha256" || wget -P "$dir" "$url.sha1"
  [ "${asset##*.}" == "tar" ] && wget -P "$dir" "${url%.tar}.docker_tag"
done


CNI_KUBERNETES_ASSETS=(
  $NEW_CNI_FILENAME
)
for asset in "${CNI_KUBERNETES_ASSETS[@]}"; do
  dir="k8s-artifacts-cni/release/$(dirname "$asset")"
  mkdir -p "$dir"
  url="https://storage.googleapis.com/k8s-artifacts-cni/release/$asset"
  wget -N -P "$dir" "$url"
  [ "${asset##*.}" != "gz" ] && wget -P "$dir" "$url.sha256" || wget -P "$dir" "$url.sha1"
  [ "${asset##*.}" == "tar" ] && wget -P "$dir" "${url%.tar}.docker_tag"
done



KOPS_ASSETS=(
  "images/protokube.tar.gz"
  "linux/amd64/nodeup"
  "linux/amd64/kops"
  "linux/amd64/utils.tar.gz"
  "linux/amd64/protokube"
  "linux/amd64/channels"
  "darwin/amd64/kops"
  "linux/arm64/nodeup"
  "linux/arm64/kops"
  "linux/arm64/utils.tar.gz"
  "linux/arm64/protokube"
  "linux/arm64/channels"
)
for asset in "${KOPS_ASSETS[@]}"; do
  kops_path="binaries/kops/$KOPS_VERSION/$asset"
  dir="$(dirname "$kops_path")"
  mkdir -p "$dir"
  url="https://kubeupv2.s3.amazonaws.com/kops/$KOPS_VERSION/$asset"
  wget -N -P "$dir" "$url"
  wget -N -P "$dir" "$url.sha256"
done

