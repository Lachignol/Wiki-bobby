#import "@preview/zebraw:0.6.1": zebraw

#show: zebraw.with(
  // copy-button : false,
  numbering: "none"
  
)
#set page(
  paper: "a4",
  margin: (x: 2cm, y: 2cm),
  // numbering: "1"
)


#align(center)[= GIT-SUBMODULES]

#linebreak()

== To clone repository, including all of its submodules: 

```sh 
git clone --recursive git\@github.com:Lachignol/project_name.git 
```

== Alternatively, you can: 

```sh 
git clone git\@github.com:Lachignol/project_name.git git submodule update --init --recursive 
```

== To add a repository to this collection:

```sh 
git submodule add -b [] git config -f .gitmodules submodule..update rebase git submodule update --remote --recursive ´´´
```

== To remove a repository from this collection: 

```sh
git submodule deinit -f rm -rf .git/modules/ git rm -f
```

