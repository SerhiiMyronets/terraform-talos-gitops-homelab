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
      numToKeep(3)
    }
  }
}