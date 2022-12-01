dashboard "dashboard" {
  title = "Home Office GitHub Dashboard POC"

  container {
    text {
      value = "Github management proof-of-concept."
      width = "12"
    }
  }

  input "organisation_selection" {
    title = "Organisation"
    type  = "select"
    width = 2
    option "org:HO-CTO" {}
    option "org:UKHomeOffice" {}
  }

  container {
    card {
      title = "Total public repos"
      query = query.public_repo_count
      width = 4
      icon  = "hashtag"
      type  = "info"
      args = {
        organisation = self.input.organisation_selection.value
      }
    }

    card {
      title = "Community Standards Health Percentage"
      label = "Health Percentage"
      query = query.community_standards
      width = 4
      type  = "info"
      args = {
        organisation = self.input.organisation_selection.value
      }
    }

    card {
      title = "Unique Contributors"
      sql   = query.unique_contributors.sql
      width = 4
      icon  = "hashtag"
      type  = "info"
    }
  }

  container {
    chart {
      title = "Repo language distribution"
      query = query.languages
      type  = "column"
      width = 12
      args = {
        organisation = self.input.organisation_selection.value
      }
    }
  }

  container {
    chart {
      title = "Contributor commits"
      sql   = query.contributor_commits.sql
      type  = "table"
      width = 6
    }

    chart {
      title = "Outside contributors"
      sql   = query.outside_contributors.sql
      type  = "table"
      width = 6
    }

    chart {
      title = "Total issues and Pull Requests"
      sql   = query.issues_prs.sql
      type  = "table"
      width = 12
    }
  }

}

# Queries 

query "public_repo_count" {
  sql = <<-EOQ
      select
        count(*) as "Total repos"
      from
        github_search_repository
      where
        query = $1;
    EOQ

  param "organisation" {}
}


query "languages" {
  sql = <<-EOQ
      select
          repo.language as "language",
          count(repo.language) as "total"
      from
          github_search_repository as repo
      where
          query = $1
      group by repo.language
      order by count(repo.language) desc;
    EOQ

  param "organisation" {}
}

query "community_standards" {
  sql = <<-EOQ
select
    CONCAT(ROUND(avg(health_percentage)), '%') as health_percentage
from
    github_search_repository as r
        left join github_community_profile as c on r.full_name =  c.repository_full_name
where
        query = $1;
    EOQ

  param "organisation" {}
}

query "unique_contributors" {
  sql = <<-EOQ
    select
    count(distinct author_login) as total_unique_contributors
from
    github_commit
where
        repository_full_name = 'HO-CTO/sre-monitoring-as-code'
  and author_login != 'dependabot[bot]'
  EOQ
}

query "contributor_commits" {
  sql = <<-EOQ
  select
    author_login,
    count(sha) as number_of_commits
from
    github_commit
where
        repository_full_name = 'HO-CTO/sre-monitoring-as-code'
  and author_login != 'dependabot[bot]'
group by author_login
order by number_of_commits desc
  EOQ
}

query "issues_prs" {
  sql = <<-EOQ
  select
    g1.repository_full_name,
    count(g1.issue_number) as number_of_open_issues,
    (select count(g2.issue_number) as number_of_opened_issues
     from github_issue g2
     where
             g2.repository_full_name = g1.repository_full_name
     group by g2.repository_full_name
    ),
    (select
         avg(age(g3.closed_at, g3.created_at)) AS average_issue_age
     from
         github_issue g3
     where
             g3.repository_full_name = g1.repository_full_name
       and state = 'closed'
     group by
         g3.repository_full_name
    ),
    (select count(pr1.issue_number) as number_of_open_pull_requests
     from github_pull_request pr1
     where
             pr1.repository_full_name = g1.repository_full_name
       and pr1.state = 'open'
     group by pr1.repository_full_name
    ),
    (select count(pr2.issue_number) as number_of_opened_pull_requests
     from github_pull_request pr2
     where
             pr2.repository_full_name = g1.repository_full_name
     group by pr2.repository_full_name
    ),
    (select
         avg(age(pr3.closed_at, pr3.created_at)) AS average_issue_age
     from
         github_pull_request pr3
     where
             pr3.repository_full_name = g1.repository_full_name
       and state = 'closed'
     group by
         pr3.repository_full_name
    )
from
    github_issue g1
where
        g1.repository_full_name = 'HO-CTO/sre-monitoring-as-code' and g1.state = 'open'
group by g1.repository_full_name
EOQ
}

query "outside_contributors" {
  query = <<-EOQ
  select
    gc.author_login,
    (
        select
            count(*)
        from
            github_my_organization
        where
            member_logins ? gc.author_login
    ) as number_of_orgs
from
    github_commit gc
where
    repository_full_name = 'HO-CTO/sre-monitoring-as-code'
group by
    gc.author_login
    EOQ
}
