# Workshop 8 Instructions

## Part 1 (Publish to Docker Hub)

### Add a Dockerfile
Add a Dockerfile to the app so that you can build and run it using Docker.

There are different approaches to writing the Dockerfile but we'd recommend starting from an [official dotnet image](https://hub.docker.com/_/microsoft-dotnet) and then [scripting the install of node/NPM](https://github.com/nodesource/distributions/blob/master/README.md).

Then use the setup commands in [during_workshop_7.md](./during_workshop_7.md) to install dependencies and build the app.

And then add an `ENTRYPOINT` that will start the app.

> Troubleshooting:
> - If you are seeing a Node Sass error, try adding the `DotnetTemplate.Web/node_modules` folder to a `.dockerignore` file to avoid copying local build artefacts/dependencies into the image.
> - To build the dotnet code you'll need the correct version of the [SDK](mcr.microsoft.com/dotnet/sdk:5.0) (Software Development Kit) dotnet Docker image.
> - Note that you won't need to run `sudo` when building the image (as the default user is root).
> - Some instructions, like installing Node, might depend on the OS of an image - for a Linux image it might not be immediately obvious which distribution you have. Running the image and accessing a terminal can provide one approach to explore for an answer but Docker Hub might offer clues too - can you spot any on the dotnet SDK page?
>   - For many images, starting the container with `docker run -it --entrypoint /bin/bash <image>` will give us access to a terminal, from where we can explore further. A command like `cat /etc/*-release` might provide us with an answer from there

### Publish manually to Docker Hub
1. Create a personal free account on [Docker Hub](https://hub.docker.com/) (if you haven't already).
2. Create a public repository in Docker Hub: https://hub.docker.com/repository/create. Don't connect it to GitHub, and name it dotnettemplate.
3. Build your Docker image locally and push it to Docker Hub. See https://docs.docker.com/docker-hub/repos/ for instructions.

### Publish to Docker Hub with GitHub Actions
You should already have a GitHub Actions workflow file which will build and test the app. Now add a new step to it which will publish the app to Docker Hub. You should be able to find an existing action to do this for you.

Try publishing the image with the branch that triggered the build. You can use the `github` context to find out the commit. See [here](https://docs.github.com/en/actions/reference/context-and-expression-syntax-for-github-actions#contexts) for details. Note that default environment variables won't be available in a `with: ` section because that's evaluated during workflow processing before it is sent to the runner.

### Test your workflow
To test that publishing to Docker Hub is working:
1. Make some change to the application code. Don't worry if you don't know anything about C#, you can try to find some text you can modify.
2. Commit your changes to git, and push them.
3. Look at GitHub and check your workflow completed successfully.
4. Ask someone else to download and run your new image from Docker Hub.

### Publish only on main
Modify the workflow so that it will only publish to Docker Hub if it's run on the main branch.

### (Stretch goal) Publish to Docker Hub with Jenkins
In one of the workshop 7 goals you were asked to set up a Jenkins job for the app (if you haven't done that yet it's worth going back to it now). Modify the Jenkinsfile so that it will publish to Docker Hub.

## Part 2 (Deploy to Heroku)

### Deploy to Heroku manually
1. Create a free Heroku account: https://signup.heroku.com/.
2. Create a new Heroku app: https://dashboard.heroku.com/new-app. Do not click the button to integrate with a GitHub repository.
3. Build your docker image locally and deploy it to Heroku. See https://devcenter.heroku.com/articles/container-registry-and-runtime for instructions. In particular you want to [push an existing image](https://devcenter.heroku.com/articles/container-registry-and-runtime#building-and-pushing-image-s) then [release the image](https://devcenter.heroku.com/articles/container-registry-and-runtime#cli). The first steps will push the docker image to Heroku's Docker Hub registry. Then the last step will deploy that image to your Heroku app.
> - The docs mention a "process-type". You want to use `web`
> - If you are using `ENTRYPOINT dotnet run`, that will not work on Heroku because of how it runs containers. You can use the "exec" syntax instead: `ENTRYPOINT ["dotnet", "run"]`
4. You should now see a log of the deployment on your Heroku app's dashboard: https://dashboard.heroku.com/apps/<HEROKU_APP_NAME> (replace <HEROKU_APP_NAME> with the name you gave your Heroku app when you created it).
5. You can see the app running by clicking the "Open app" button on the app's dashboard, or by going to <HEROKU_APP_NAME>.herokuapp.com (replace <HEROKU_APP_NAME> with the name you gave your Heroku app when you created it).

### Deploy to Heroku with GitHub Actions
Add a new step to your workflow which will deploy to Heroku. You should be able to find an existing action to do this for you. As with the publish step, make sure this only runs on the main branch.

<details>
<summary>Hint</summary>

You might want to look [at this action](https://github.com/marketplace/actions/deploy-to-heroku).

<details>
<summary>Hint</summary>

See the example ["Deploy with Docker"](https://github.com/marketplace/actions/deploy-to-heroku#deploy-with-docker) section, and don't forget the `useddocker` flag
</details>
</details>

### Multistage Dockerfile
If you haven't already, try writing your Dockerfile as [a multistage build](https://docs.docker.com/samples/dotnetcore/#create-a-dockerfile-for-an-aspnet-core-application). For an example that more closely matches this project see [here](https://github.com/dotnet/dotnet-docker/blob/main/samples/aspnetapp/Dockerfile)
```
FROM <parent-image-1> as build-stage
# Some commands

FROM <parent-image-2>
# Some commands
```
In this way you can use a large parent (`dotnet/sdk`) to build the app and then use a smaller parent (`dotnet/aspnet`) for your final image that will run the application. The second stage just needs to copy the build artefact from the earlier stage with a COPY command of the form: `COPY --from=build-stage ./source ./destination`.

To make the example work:
- Replace any mention of "aspnetapp" with "DotnetTemplate.Web". 
- Remove the "--no-restore" option from the publish command
- Keep your instructions that install node, but you no longer need the "npm ..." commands (they are included in DotnetTemplate.Web.csproj and run as part of `dotnet publish`).

You should see a decrease in the image size from ~1.5GB to a few hundred MB. This will make uploads to Heroku a lot faster.

### (Stretch goal) Healthcheck
Sometimes the build, tests and deployment will all succeed, however the app won't actually run. In this case it can be useful if your workflow can tell you if this has happened. Modify your workflow so that it does a healthcheck.

As part of this it can be useful to add a healthcheck endpoint to the app, see [this microsoft guide](https://docs.microsoft.com/en-us/aspnet/core/host-and-deploy/health-checks?view=aspnetcore-5.0#basic-health-probe) for an example of how to do this. This article is long and detailed, and that can make it look intimidating - but everything we need to know is just in the "Basic health probe" section. Try working through it! You should find that we can add this healthcheck endpoint with just two lines of code.

### (Stretch goal) Handle failure
How would you handle failure, for example if the healthcheck in the previous step fails? Write a custom action that will automatically roll-back a failed Heroku deployment. Make sure it sends an appropriate alert! Find a way to break your application and check this works.

### (Stretch goal) Monitor for failure
Failures don't always happen immediately after a deployment. Sometimes runtime issues will only emerge after minutes, hours or days in production. Set up a separate workflow which will use your healthcheck endpoint and send a notification if the healthcheck fails. Make sure this workflow runs every 5 minutes. Hint: https://docs.github.com/en/actions/reference/workflow-syntax-for-github-actions#onschedule.

### (Stretch goal) Multiple environments
Try making your workflow release to a different Heroku app environment for each branch of your repository.

### (Stretch goal) Promote when manually triggered
Currently we'll deploy every time a change is pushed to the main branch. However you might want to have more control over when deployments happen. Modify your Heroku and workflow setup so your main branch releases to a staging environment, and you instead manually trigger a workflow to release to production. 

### (Stretch goal) Jenkins
In one of the workshop 7 goals you were asked to set up a Jenkins job for the app (if you haven't done that yet it's worth going back to it now). Now modify the Jenkinsfile so that it will deploy to Heroku.
