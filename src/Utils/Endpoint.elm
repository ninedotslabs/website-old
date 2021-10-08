module Utils.Endpoint exposing (..)


homeGH : String
homeGH =
    "https://api.github.com"


apiGHOrgMembers : String
apiGHOrgMembers =
    homeGH ++ "/orgs/ninedotslabs/members"


apiGHOrgRepos : String
apiGHOrgRepos =
    homeGH ++ "/orgs/ninedotslabs/repos"
