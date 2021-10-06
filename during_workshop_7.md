# Workshop 7 Instructions

## Part 1 (Github Actions)

### Step 1 - Get the code

We'll be working on top of this repository. Because you'll need to change some settings on the repository later in the workshop, it's recommended that you [fork](https://docs.github.com/en/github/getting-started-with-github/fork-a-repo) the repository instead of cloning it. To do that:
1. Click the Fork button in the top right on the repository page.
2. Select your GitHub user when it asks you where you should fork it to.
3. This should take you to a fork of the repository on your account, e.g. <https://github.com/MyUser/DevOps-Course-Workshop-Module-07-Learners> where MyUser will be replaced by your username.
4. You can now clone and push to that repository as normal.

### Step 2 - Set up the app

This repository contains a minimal .NET Core app. You don't need to worry about exactly how the code works, but you should be able to build, test and run it. It uses [npm](https://www.npmjs.com/) which is a package manager for the Node JavaScript platform. **If you are struggling to run the code locally, you should skip to step 3 before spending too much time trying to resolve the issue.** It's only preferable to run it locally first to better understand what you want GitHub Actions to replicate.

#### Build
1. Run `dotnet build` from the terminal in the project folder. This will build the C# code.
    * If you get errors resolving NuGet packages try running `dotnet nuget add source https://api.nuget.org/v3/index.json -n nuget.org` to add the main NuGet registry as a package source.
    You can use `dotnet nuget list source` to see what package sources NuGet is using.
2. From the DotnetTemplate.Web folder, run `npm install` (first time only) and then `npm run build`. This will build the TypeScript code.
    * If you are on Windows and see errors during installation containing "gyp ERR", you may need to first run `npm install --global windows-build-tools` (and restart your terminal).

#### Run
1. Run `dotnet run` in the DotnetTemplate.Web folder. This will start the app.
2. You can now see the website by going to [http://localhost:5000/](http://localhost:5000/). You should see something like the image below.

![Mini app](img/mini-app.png)

#### Test
1. Run `dotnet test` inside the project folder. This will run the C# tests in the DotnetTemplate.Web.Tests project.
2. Run `npm t` inside the DotnetTemplate.Web folder. This will run the TypeScript tests in DotnetTemplate.Web/Scripts/spec. They're run using [Jasmine](https://jasmine.github.io/).
3. Run `npm run lint` inside the DotnetTemplate.Web folder. This will run linting on the TypeScript code, using [eslint](https://eslint.org/). Linting refers to checking the codebase for mistakes, either functional or stylistic. This project's linting currently reports zero errors, two warnings.

### Step 3 - Set up GitHub Actions

1. Create the config file for your continuous integration pipeline:
    * Create a folder called ".github" at the root of the repository.
    * Inside there, create a "workflows" folder.
    * Inside there create a file: you can name it whatever you like, although it needs to have a .yml extension, e.g. continuous-integration-workflow.yml.
2. Implement a basic workflow:
```yaml
name: Continuous Integration
on: [push]                      # Will make the workflow run every time you push to any branch

jobs:
  build:
    name: Build and test
    runs-on: ubuntu-latest      # Sets the build environment a machine with the latest Ubuntu installed
    steps:
    - uses: actions/checkout@v2 # Adds a step to checkout the repository code
```
3. Commit and push your changes to a branch on your repository.
4. On your repository page, navigate to the Actions tab. 
5. You should see a table of workflows. This should have one entry with a name matching your latest commit message. Select this entry.
6. On the next page click "Build and test" on the left. This should show you the full output of the workflow which ran when you pushed to your branch. See [the documentation](https://docs.github.com/en/actions/configuring-and-managing-workflows/managing-a-workflow-run) for more details on how to view the output from the workflow.

See [the GitHub documentation](https://docs.github.com/en/actions/configuring-and-managing-workflows/configuring-and-managing-workflow-files-and-runs) for more details on how to set up GitHub Actions and <https://docs.github.com/en/actions/reference/workflow-syntax-for-github-actions> for more details on the syntax of the workflow file.

### Step 4 - Add more actions
Currently our workflow only checks out the code, which isn't that useful. We want to add some more useful steps to the workflow file. Each step in the workflow file either needs to:
* Specify `run` to run a command as you would in the terminal, for example:
```yaml
name: Continuous Integration
on: [push]

jobs:
  build:
    name: Build and test
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2


    - name: Hello world       # Name of step
      run: echo 'Hello world' # Command to run
```
* Specify `uses` followed by the name of the action. The name of the action is of the form `GitHubUsername/RepositoryName` and you can find them by searching the [marketplace](https://github.com/marketplace?type=actions). Anyone can publish actions - you could create your own or fork an existing one. If it is supplied by GitHub themselves, the username will be `actions`. For example:
```yaml
name: Continuous Integration
on: [push]

jobs:
  build:
    name: Build and test
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2

    - name: Hello world
      uses: actions/hello-world-javascript-action@v1.1 # Name of the action. This uses https://github.com/actions/hello-world-javascript-action
      with:                                            # This section is needed if you need to pass arguments to the action
        who-to-greet: 'Mona the Octocat'
```

You should amend your workflow file so that it:
1. Builds the C# code.
2. Runs the C# tests.
3. Builds the TypeScript code.
4. Runs the linter on the TypeScript code.
5. Runs the TypeScript tests.

### (Stretch goal) Slack notifications
To make sure people are aware when there are issues with the build, it can be useful to send a slack notification at the end of the workflow.

**Before attempting this step please create your own personal slack workspace. This is free and can be set up [here](https://slack.com/create).**

1. Add a slack notification at the end of the workflow. To make this work you will need to use the slack app [incoming webhooks](https://softwire.slack.com/apps/A0F7XDUAZ-incoming-webhooks?next_id=0), make sure this has been installed in the slack workspace you're using.
2. Make the workflow post a different message if the workflow failed, so that it's obvious if the workflow failed.
3. Make the workflow post a different message if the workflow was cancelled.

### (Stretch goal) Workflow status badge
Add a [workflow status badge](https://docs.github.com/en/free-pro-team@latest/actions/managing-workflow-runs/adding-a-workflow-status-badge) to your repository.

### (Stretch goal) Change when the workflow is run
Change your workflow so that it only runs when pushing to the main branch or by raising a PR. Is there a way to ensure that no one can update the main branch except through a PR that has passed the workflow?

## Part 2 (Jenkins)

### Step 1 - Run Jenkins locally
There are two options for running Jenkins locally, you can either install Jenkins or run it through Docker. We would recommend running Jenkins through Docker and the instructions for that are [here](https://www.jenkins.io/doc/book/installing/#docker).

### Step 2 - Set up Jenkins
Once you've done the step above you should have Jenkins running on <http://localhost:8080/>. If you go to this url in a browser it should show you a setup page.
1. Login with the password you got from the logs when starting Jenkins. **Hint:** You can run `docker logs your_container` to access a container's logs. Run `docker container ls` to view a list of running containers.
2. Now you have the option to select some initial plugins. Either select the suggested plugins or if you customise it, make sure you include the "GitHub", "Docker" and "Docker Pipeline" plugins. We won't need any others right away, and you can add more later.
3. Create an admin user.
4. Use the default Jenkins URL (<http://localhost:8080>)

You should now see the Jenkins dashboard.

### Step 3 - Set up a Jenkins build
We now want to get Jenkins to build our app. To do this you need to create a job on Jenkins for our app and create a [Jenkinsfile](https://www.jenkins.io/doc/book/pipeline/jenkinsfile/) in your repository to define what the job should do.

#### Create a Jenkins job
From your Jenkins dashboard:
1. Select New Item.
2. Set it to a multibranch pipeline. This means the job will scan your repository for branches and run the job on any branch with a Jenkinsfile.
3. Leave all the defaults other than setting the branch sources to GitHub. Leave the defaults for the branch source other than setting the repository url to your repository url. You may notice a warning about not using GitHub credentials at this point. This is fine, as we're just reading from a public repository we don't need credentials. If we were using a private repository or we were writing to the repository during the job, then we would need to set up credentials.
4. Click Save to create the Jenkins job.

#### Create a Jenkinsfile
See <https://www.jenkins.io/doc/book/pipeline/jenkinsfile/> for details on how to create a Jenkinsfile. We want to add the same steps as for the GitHub Actions workflow so that it:
1. Builds the C# code.
2. Runs the C# tests.
3. Builds the TypeScript code.
4. Runs the linter on the TypeScript code.
5. Runs the TypeScript tests.

You have 2 options for installing .NET Core & npm inside Jenkins:
1. Make installation separate build stages
    * This is not ideal as you will have to run the installation on each build
2. [Specify containers to run stages of the Jenkins pipeline with .NET Core and npm pre-installed](https://www.jenkins.io/doc/book/pipeline/docker/)
    * The simplest approach is to have one stage for your `npm` commands and a second stage for your `dotnet` commands, because each stage can have its own agent. You will have to specify `agent none` at the top of the pipeline. 
    * There are some pre-built images for npm (e.g. `node:16-alpine`)
    * Similarly for .NET you can use [Microsoft's image](https://hub.docker.com/_/microsoft-dotnet-sdk). You may need to set an environment variable `DOTNET_CLI_HOME` (e.g. to `"/tmp/dotnet_cli_home"`) in your Jenkinsfile for the dotnet CLI to work correctly.

<details>
<summary>Hints</summary>

* You'll need to use a `dir` block for some steps to run them inside the `DotnetTemplate.Web` directory.
* If Jenkins starts rate limiting your repository scanning you can go to "Manage Jenkins" -> "Configure System" and change "Github API usage rate limiting strategy" to "Throttle at/near rate limit". Adding credentials to your pipeline configuration will also increase the limit.

</details>

#### Run the Jenkins job
1. Commit and push your new Jenkinsfile.
2. From your Jenkins dashboard select the job you created.
3. Click "Scan Multibranch Pipeline Now". This will scan the repository for branches and run the job on any branch with a Jenkinsfile.
4. Select your branch, which should appear under "Branches" once the scan is done.
5. You should see a stage view of the build, showing each stage in the Jenkinsfile. If the stage succeeded it will be green, if it failed it will be red.
6. Select the most recent build from the build history on the left.
7. Click "Console Output" to view the full logs from the build.

### (Stretch goal) Code coverage
We want high _test coverage_, meaningfully testing as much of the functionality of the application as possible. _Code coverage_ is a more naive metric - it simply checks which lines of code were executed during the test run. But higher code coverage is usually a good thing and it can still usefully flag which parts of the codebase are definitely untested. So let's include code coverage in our CI pipeline.

First check it works manually. From the DotnetTemplate.Web folder, run the command `npm run test-with-coverage`. This runs the frontend tests and calculates code coverage at the same time.

It produces two reports: one in HTML form that you can open in your browser (DotnetTemplate.Web/coverage/index.html) and one in XML that we will get Jenkins to parse.

Try adding code coverage to Jenkins:

1. Install the [Code Coverage API](https://plugins.jenkins.io/code-coverage-api/) plugin on Jenkins.
2. Change your Jenkins pipeline to run the tests with code coverage.
3. Add a step after running the tests to publish coverage. You can see a simple example of the command if you scroll down the Code Coverage API documentation, to the "pipeline example". You will want to use the "istanbulCoberturaAdapter", and the report to publish is "cobertura-coverage.xml" in the coverage folder. 
4. You should see a code coverage report appear on the build's page after it completes. Click through to see details.

Now let's enforce high code coverage:

1. Configure it to fail the build for code coverage below 90%. You may find it easiest to use the Jenkins [Snippet Generator](https://www.jenkins.io/doc/book/pipeline/getting-started/#snippet-generator). 
2. Push your change and watch the build go red!
3. Edit the `DotnetTemplate.Web/Scripts/spec/exampleSpec.ts` file:
  * Update the import statement: `import { functionOne, functionTwo } from '../home/example';`
  * Invoke functionTwo on a new line in the test `functionTwo();`
4. Push the change and observe the build go green again! You can also view the code coverage history.

### (Stretch goal) Slack notifications
Like for the GitHub Actions workflow, add slack notification to the Jenkins job. To make this work you will need to use the Slack app [Jenkins CI](https://slack.com/apps/A0F7VRFKN-jenkins-ci?next_id=0), make sure this has been installed in the slack workspace you're using.

> Note that their documentation may be slightly out of date and not quite match the page you see in Jenkins.

### (Stretch goal) Use a Single Build Agent for the Jenkins Pipeline
Can you create a single container that can be used as the sole build agent for the entire multistage Jenkins pipeline? You might need to do this to run end to end tests for example.
