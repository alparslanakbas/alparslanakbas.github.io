---
title: "Built-In Container Support in .NET: No Dockerfile Needed"
description: "How to containerize a .NET application straight from the SDK using dotnet publish, without writing or maintaining a Dockerfile."
date: 2024-12-03 20:00 +0300
categories: [DevOps, Docker]
tags: [dotnet-7, docker, containers, aspnet-core]
image:
  path: /assets/img/posts/built-in-container-support-in-net/cover.webp
  alt: 'Title card: Built-In Container Support in .NET'
  lqip: "data:image/webp;base64,UklGRmQAAABXRUJQVlA4IFgAAACQAwCdASoYAA0APu1iqU2ppaQiMAgBMB2JZQAAWph700DxGeJgAP7sEYgkbVHHOD0zK2ThNQwmJEPCoQC0LL7Eab25IqiUqpFJK3okFcychmsL/x/epJgA"
---

## Introduction

Hello,

In this article, we will explore the feature introduced with .NET 7 and later versions that allows applications to be containerized without the need for a Dockerfile. At the same time, we will examine the built-in container support in .NET.

Yes, Microsoft, starting with the .NET 7 SDK, has introduced a completely new approach that eliminates the dependency on the Dockerfile for containerizing applications. This streamlines the DevOps process by removing the need for maintaining an additional file and simplifies the workload. As a result, the containerization process for applications has been made easier and more straightforward.

The core idea behind this approach stems from the fact that, in many software applications, developers often spend significant time and effort dealing with lengthy Dockerfile configurations to enable containerization. However, starting with .NET 7, this effort has been reduced by enabling the creation and deployment of Docker images directly through the .NET CLI tool, leveraging built-in capabilities. This makes the process more efficient and manageable.

Now, we will revisit how a .NET application is containerized using a Dockerfile and, in parallel, demonstrate how this can be done without a Dockerfile. We will evaluate both methods comparatively. If you've used Docker before — [running a Redis server in a container](/posts/run-redis-with-docker/), for example — the commands below will feel familiar. Let's dive in!

## Let's Starting

First, let's develop an ASP.NET Core WEB API application with the following endpoint:

```csharp
var builder = WebApplication.CreateBuilder(args);
 
var app = builder.Build();
 
app.MapGet("/", () => "Hello World!");
 
app.Run();
```

Next, to dockerize this application, let's create a Dockerfile with the following content:

```yml
FROM mcr.microsoft.com/dotnet/sdk:8.0 as build
WORKDIR /src
COPY *.csproj .
RUN dotnet restore
COPY . .
RUN dotnet publish -c Release -o /publish
 
FROM mcr.microsoft.com/dotnet/aspnet:8.0 as runtime
WORKDIR /publish
COPY --from=build /publish .
ENV ASPNETCORE_URLS=http://+:5000
EXPOSE 5000
ENTRYPOINT ["dotnet", "Docker.Example.dll"]
```

Now that the Dockerfile is ready, let's create an image using the following command:

```bash
docker build -t docker-example .
```

After completing this process, we can create a container from the generated image using the command:

```bash
docker run -p 5000:5000 --name docker-example-container docker-example
```

And you will see this output:

```bash
Hello World!
```

You might be wondering, "What exactly is difficult or complicated about this?" And yes, as seen above, there isn’t anything particularly challenging here. In its simplest form, this is the approach we take when dockerizing a .NET application. However, as the application’s requirements and project complexity increase, the content of the Dockerfile will inevitably grow. Consequently, maintaining this file becomes an additional overhead.

To address such scenarios, Microsoft has introduced built-in container support in .NET, allowing developers to dockerize applications without relying on a Dockerfile.

With this support, we can create a Docker image and launch a container from it with a single command:

```bash
dotnet publish --os linux --arch x64 /t:PublishContainer
```

> This command used to be written `-p:PublishProfile=DefaultContainer -p:ContainerImageName=docker-example`. That still works, but it's the old .NET 7-era form — `/t:PublishContainer` targeting the publish target directly is what the current docs use, and `ContainerImageName` itself has been deprecated since .NET 8 in favor of `ContainerRepository` (same idea, new name). If you don't set a name at all, the image name defaults to your project's `AssemblyName`.
{: .prompt-info }

You can set the image name, and a few other options, in your .csproj instead of passing them on the command line every time:

```csharp
<Project Sdk="Microsoft.NET.Sdk.Web">
  <PropertyGroup>
    .
    .
    .
    <ContainerRepository>docker-example-container</ContainerRepository>
    <ContainerImageTags>1.1.0;latest</ContainerImageTags>
  </PropertyGroup>
  <ItemGroup>
    .
    .
    .
  </ItemGroup>
</Project>
```

With those set, the command shrinks back down to:

```bash
dotnet publish --os linux --arch x64 /t:PublishContainer
```

Add a `RuntimeIdentifier` and you don't even need to pass `--os`/`--arch` on the command line:

```csharp
<ContainerRepository>docker-example-container</ContainerRepository>
<ContainerImageTags>1.1.0;latest</ContainerImageTags>
<RuntimeIdentifier>linux-x64</RuntimeIdentifier>
```

```bash
dotnet publish /t:PublishContainer
```

As a result of this process, if you check your images in Docker, you will see that an image has been created with the name you specified.

![Desktop View](/assets/img/posts/Built-In-Container-Support-in-NET-Dockerizing-NET-Applications-Without-a-Dockerfile-1.webp)
_NET-Dockerizing-NET-Applications-Without-a-Dockerfile_

Beyond these options, you can also customize the image to be created using the properties described below:

* **ContainerBaseImage**: This property allows you to control the base image used to build .NET applications. By default, the SDK uses the **mcr.microsoft.com/dotnet/aspnet** image.
* **ContainerRepository**: This property enables you to change the name of the image (the modern replacement for `ContainerImageName`).
* **ContainerPort**: This property allows you to specify the container's port.
Additionally, you can define environment variables using the **ContainerEnvironmentVariable** property as shown below.

```csharp
<Project Sdk="Microsoft.NET.Sdk.Web">
  .
  .
  .
  <ItemGroup>
    <ContainerEnvironmentVariable Include="Example_Environment_Variable" Value="Trace" />
  </ItemGroup>
</Project>
```

## What's Changed Since .NET 7

The core workflow above hasn't changed since .NET 7 introduced it, but a couple of details have:

* **ASP.NET Core and Worker SDK projects (like the one used here) already support this out of the box.** Console apps were the odd one out — they needed an explicit `<EnableSdkContainerSupport>true</EnableSdkContainerSupport>` opt-in. .NET 10 removed that gap: console apps get the same zero-config experience now.
* **Multi-architecture images** (building one image that works on both `linux-x64` and `linux-arm64`, for example) are supported starting with SDK 8.0.405+ and 9.0.102+, if you're deploying to mixed-architecture infrastructure.

Once the image exists, running it locally to sanity-check it before pushing anywhere is the same as any other image:

```bash
docker run -p 5000:5000 --rm docker-example-container
curl http://localhost:5000/
```

## Conclusion

The .NET architecture has shifted its focus toward enabling us to create Docker images for our applications in a much simpler and more flexible way, without the need for standard Dockerfile approaches. This approach not only accelerates our development process but also, in my opinion, makes a significant difference in simplifying containerization. It pairs well with the [rate limiting middleware](/posts/dotnet7-how-to-use-rate-limitter/) covered in an earlier post — both are examples of production concerns that used to require third-party tooling and now ship in the SDK itself.

See you in my upcoming articles, and happy coding..

![Desktop View](/assets/img/posts/thanks-for-reading.webp)
_Thanks For Reading_
