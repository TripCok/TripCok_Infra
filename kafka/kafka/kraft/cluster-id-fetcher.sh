# S3에서 클러스터 ID 다운로드
aws s3 cp s3://tripcok/kafka-cluster-id/cluster.id /tmp/kraft-clusterid/cluster.id
echo "클러스터 ID 다운로드 완료: $(cat /tmp/kraft-clusterid/cluster.id)"
