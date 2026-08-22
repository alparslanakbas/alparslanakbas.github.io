---
icon: fas fa-diagram-project
order: 4
description: >-
  A few things Alparslan Akbaş has built — a live production app, published
  NuGet packages, and open-source experiments in .NET.
---

A short selection — not everything, just the ones worth your time. The rest is on [GitHub](https://github.com/alparslanakbas?tab=repositories).

## ProteinAvcısı

A live price-tracking site for sports supplement brands in Turkey. Built with .NET and Angular, it scrapes prices across multiple retailers, keeps a real price history instead of trusting retailers' own "was/now" claims, and surfaces genuine discounts. Deployed and running.

[proteinavcisi.com.tr](https://www.proteinavcisi.com.tr) · [Source](https://github.com/alparslanakbas/protein-avcisi)

## Middleware Packages for ASP.NET Core

Two small NuGet packages that grew out of patterns I kept rewriting on client projects. **CD.RequestResponse.Middleware** logs HTTP requests and responses with configurable fields and log levels; **CD.File-Logger.Middleware** extends it to persist those logs to disk.

[CD.RequestResponse.Middleware](https://www.nuget.org/packages/CD.RequestResponse.Middleware) · [CD.File-Logger.Middleware](https://www.nuget.org/packages/CD.File-Logger.Middleware) · [Source](https://github.com/alparslanakbas/request-response-nuget-package)

## CD.GenericRepository

A lightweight generic repository pattern implementation for .NET with Entity Framework Core — the CRUD and query boilerplate I got tired of rewriting per project.

[Source](https://github.com/alparslanakbas/CD.GenericRepository)

## ReqMint

An HTTP client built from scratch in .NET — designing it to be fast and unfussy rather than bolting features onto a bloated UI. Actively in development.

[Source](https://github.com/alparslanakbas/ReqMint)

## Multi-Tenant Social Media Platform

A Twitter-inspired social platform built in .NET Core to explore multi-tenancy properly — isolated data per tenant on shared infrastructure, without the usual shortcuts.

[Source](https://github.com/alparslanakbas/multi-tenancy-social-media)

## AutoCodeGenerationVSIX

A Visual Studio extension for quick code-generation shortcuts — the one tooling project on this list, everything else here is backend/web.

[Source](https://github.com/alparslanakbas/AutoCodeGenerationVSIX)
