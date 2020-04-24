package test

import (
	"io/ioutil"
	"os"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/magiconair/properties/assert"
)

func TestLabClusterCreation(t *testing.T) {
	t.Parallel()

	nodeCount := 1

	terraformOptions := &terraform.Options{
		TerraformDir: "../",

		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"cluster_name": "test",
			"node_count":   nodeCount,
		},

		// Disable colors in Terraform commands so its easier to parse stdout/stderr
		NoColor: true,
	}

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	// Run `terraform output` to get the values of output variables
	kubeconfig := terraform.Output(t, terraformOptions, "kubeconfig")

	kubeconfigFile, err := ioutil.TempFile(os.TempDir(), "prefix-")
	if err != nil {
		t.Fatal("Cannot create temporary file", err)
	}

	defer os.Remove(kubeconfigFile.Name())

	text := []byte(kubeconfig)
	if _, err = kubeconfigFile.Write(text); err != nil {
		t.Fatal("Failed to write to temporary file", err)
	}
	if err := kubeconfigFile.Close(); err != nil {
		t.Fatal(err)
	}

	options := k8s.NewKubectlOptions("", kubeconfigFile.Name(), "default")

	k8s.WaitUntilAllNodesReady(t, options, 10, 1*time.Second)

	nodes := k8s.GetNodes(t, options)

	assert.Equal(t, len(nodes), nodeCount)
}
