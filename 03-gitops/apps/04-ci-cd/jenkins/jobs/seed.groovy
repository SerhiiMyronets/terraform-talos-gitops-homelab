multibranchPipelineJob('currencyservice') {
  branchSources {
    github {
      id('currencyservice-github')
      repoOwner('DevSecOps-homelab')
      repository('currencyservice')
      scanCredentialsId('github-access-token')
    }
  }
  orphanedItemStrategy {
    discardOldItems {
      numToKeep(10)
    }
  }
  triggers {
    periodic(1)
  }
}