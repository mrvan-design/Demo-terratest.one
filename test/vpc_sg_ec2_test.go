package test

import (
	"context"
	"testing"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/ec2"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestTerraformVPCSGEC2(t *testing.T) {
	terraformOptions := &terraform.Options{
		TerraformDir: "../terraform",
		EnvVars: map[string]string{
			"AWS_ACCESS_KEY_ID":     "test",
			"AWS_SECRET_ACCESS_KEY": "test",
			"AWS_DEFAULT_REGION":    "us-east-1",
		},
	}

	// Cleanup resources sau khi test xong
	defer terraform.Destroy(t, terraformOptions)

	// Apply Terraform
	terraform.InitAndApply(t, terraformOptions)

	// Lấy output từ Terraform
	vpcID := terraform.Output(t, terraformOptions, "vpc_id")
	subnetID := terraform.Output(t, terraformOptions, "subnet_id")
	sgID := terraform.Output(t, terraformOptions, "sg_id")

	// Load AWS config với endpoint LocalStack
	cfg, err := config.LoadDefaultConfig(
		context.TODO(),
		config.WithRegion("us-east-1"),
		config.WithEndpointResolver(
			aws.EndpointResolverFunc(func(service, region string) (aws.Endpoint, error) {
				return aws.Endpoint{
					URL:           "http://localhost:4566",
					SigningRegion: "us-east-1",
				}, nil
			}),
		),
	)
	if err != nil {
		t.Fatal(err)
	}

	client := ec2.NewFromConfig(cfg)

	// Verify VPC
	vpcResp, err := client.DescribeVpcs(context.TODO(), &ec2.DescribeVpcsInput{
		VpcIds: []string{vpcID},
	})
	assert.NoError(t, err)
	assert.Equal(t, 1, len(vpcResp.Vpcs))

	// Verify Subnet
	subResp, err := client.DescribeSubnets(context.TODO(), &ec2.DescribeSubnetsInput{
		SubnetIds: []string{subnetID},
	})
	assert.NoError(t, err)
	assert.Equal(t, 1, len(subResp.Subnets))
	assert.Equal(t, vpcID, *subResp.Subnets[0].VpcId)

	// Verify Security Group
	sgResp, err := client.DescribeSecurityGroups(context.TODO(), &ec2.DescribeSecurityGroupsInput{
		GroupIds: []string{sgID},
	})
	assert.NoError(t, err)
	assert.Equal(t, 1, len(sgResp.SecurityGroups))

	// ⚠️ EC2 instance không verify vì LocalStack không tạo thật AMI
}
