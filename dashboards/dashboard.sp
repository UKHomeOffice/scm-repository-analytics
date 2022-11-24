dashboard "dashboard" {
  title = "Home Office GitHub Dashboard POC"

  image {
    sql = <<-EOQ
        select 
          avatar_url as "Avatar"
        from
          github_organization
        where
          login = 'UKHomeOffice';
    EOQ
    width = 2
    }
    
  text {
    value = "Github management proof-of-concept."
  }

    card {
    sql = query.test_public_repo.sql
  }

    chart {
      title = "Languages"
      sql = query.test_repo_langs.sql
      type  = "column"
      width = 6
    }

}

query "test_public_repo" {
    sql = <<-EOQ
      select
        count(*) as "Total repos"
      from
        github_search_repository
      where
        query = 'org:UKHomeOffice';
    EOQ
}

query "test_repo_langs" {
    sql = <<-EOQ
      select
          repo.language as "language",
          count(repo.language) as "total"
      from
          github_search_repository as repo
      where
          query = 'org:UKHomeOffice'
      group by repo.language
      order by count(repo.language) desc;
    EOQ
}