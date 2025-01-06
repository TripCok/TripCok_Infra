CLUSTER_ID=$(kafka-storage random-uuid)
echo "생성된 클러스터 ID: $CLUSTER_ID"

# S3 버킷에 업로드
echo "$CLUSTER_ID" | aws s3 cp - s3://tripcok/kafka-cluster-id/cluster.id
echo "클러스터 ID를 S3에 업로드했습니다: $CLUSTER_ID"
