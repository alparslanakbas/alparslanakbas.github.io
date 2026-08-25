---
title: Starting A Blog Hosted On Github Pages
description: "A practical walkthrough for launching a free developer blog on GitHub Pages with Jekyll and the Chirpy theme, including custom domain setup."
date: 2024-07-09 22:37 +0300
translation_key: how-to-build-personel-web-blog-site
categories: [Meta, Blogging]
tags: [jekyll, github-pages, blogging, custom-domain]
image:
  path: /assets/img/posts/how-to-build-personel-web-blog-site/cover.webp
  alt: 'Title card: Starting A Blog Hosted On Github Pages'
  lqip: "data:image/webp;base64,UklGRmIAAABXRUJQVlA4IFYAAABQAwCdASoYAA0APu1iqU2ppaOiMAgBMB2JZQAAWo6r2+2MYAD+7BGIJG1RyhQfceGIxMp+E3oDvdMzsTahYWr3NJgLY++bWpI2ahyF/fyGmf71JMAAAA=="
---

## My First Ever Blog Post

I've been thinking about starting a blog for a while now and I was procrastinating quite a bit. But, I finally did it and here I am writing my first ever blog post. Suprisingly enough, it will be about my experience setting up my blog and how you can do it too.

![Desktop View](/assets/img/posts/blog_meme.webp)
_Scenario of a developer starting a blog_

### [YouTube Video Jekyll Tutorial](https://www.youtube.com/watch?v=F8iOU1ci19Q)

## Why Github Pages ?

I'm a progammer. I've always wanted to have a personal website to showcase my projects and share my thoughts. I've looked into various blogging platforms like [Wordpress](https://wordpress.com/), [Medium](https://medium.com/), [Substack](https://substack.com), and [Ghost](https://ghost.org/). But, I chose Github Pages with Jekyll because I wanted to have:

1. Full control over my blog and I wanted to customize it to my taste.
2. A blog that is free and doesn't require me to pay for hosting.
3. A blog that is simple, fast and easy to maintain doesn't require me to spend hours to configure it.

Did I convince you? OK, now let's break down the steps to setup your blogging site.

## Step 1: Decide Your Theme

This step is to quickly browse through the various Jekyll themes available on various websites and pick one that fits your taste

Few sites where you can grab these templates:

* <https://jekyllthemes.io/>
* <https://jekyllthemes.org/>
* <https://jekyll-themes.com/>
* <https://jamstackthemes.dev/ssg/jekyll/>

I personally picked the [Chirpy theme](https://github.com/cotes2020/chirpy-starter/) since it fits my expectations and it has a Dark theme.

## Step 2: Activate Github Pages

Once you pick the Jekyll theme, it's time to host it on Github Pages. The theme you picked usually comes with a set of instructions to configure and the instruction varies between different themes.

For Chirpy theme, the instructions are as follows:

1. Use the [template](https://github.com/cotes2020/chirpy-starter/generate) to create your own repository.
    * Make sure to name it as `<your-gh-username>.github.io`
    * After doing this step Github actions will build and deploy your blog automatically to `<your-gh-username>.github.io`
    * But you don't want just a template, you want to customized it to yourself. So, let's move on to the next step.
2. Clone the repository you just created.
3. Install Ruby and Jekyll on your machine through the [official guide](https://jekyllrb.com/docs/installation/).
4. Run `bundle install` to install the required gems.
5. Update the variables of `_config.yml` as needed. Some of them are typical options.
    * `url` is the address of your website
    * `avatar` is the profile picture in the sidebar
    * `timezone` is used to display the date and time of your posts
    * `lang` is the language of the site
6. Run `bundle exec jekyll s` to start the local server.

![Template Blog](/assets/img/posts/template-blog.webp)
_The original template you should see_

If you face any issues, you can refer to the [Chripy theme's Getting started guide](https://chirpy.cotes.page/posts/getting-started/).

## Step 3: Setup Your Custom Root Domain

You need to visit one of the domain name registrars to buy a custom domain. There are multiple registrars to choose from:

* [GoDaddy](https://www.godaddy.com/)
* [Namecheap](https://www.namecheap.com/)
* [Cloudflare Registrar](https://www.cloudflare.com/products/registrar/) — sells domains at cost (no markup), which is unusual among registrars

(Google Domains, which used to be a common recommendation here, shut down in 2024 and migrated all its customers to Squarespace — it's no longer an option for new registrations.)

### Configure Your Domain

After you purchase your domain, go into your domain management portal, click on manage DNS and add `A` type DNS records for github pages.

| Type | Data |
| ------ | ------ |
| A | 185.199.108.153 |
| A | 185.199.109.153 |
| A | 185.199.110.153 |
| A | 185.199.111.153 |
| CNAME | gh-username.github.io |

_(These `A` type DNS records map your domain name to the Github's IP address)_

### Configure Github Pages

Now that you have your domain's DNS setup, Let's head back to Github and configure your Github Pages to use your custom domain.

1. Go to your **repository's settings** page.
2. Scroll down to the **Pages** section.
3. Under **Custom domain** enter your domain name and click **Save**.

![Custom Domain](/assets/img/posts/custom-domain.webp)
_My Github Pages Custom Domain page_

_**Best Practice :**_ Click on **Enforce HTTPS** to serve your blog via secure SSL connection. Your site will be configured with a free SSL certificate from [Let's Encrypt](https://letsencrypt.org/).

Hope you found this article useful. If you have any questions, you can check my [blog's repo](https://github.com/alparslanakbas/alparslanakbas.github.io) on Github or feel free to reach out to me on [LinkedIn](https://www.linkedin.com/in/alparslanakbas/).

## A Quick Update

This post is the oldest one on the blog, and a few things have held up better than others. The Chirpy theme is still here (now a few major versions newer). The custom-domain steps above are still accurate — GitHub's DNS records haven't changed. What did change: I ended up deciding _against_ buying a custom domain for this specific blog, sticking with `alparslanakbas.github.io` instead — there's no SEO penalty for staying on a GitHub Pages subdomain, and it was one less thing to maintain. Worth knowing both options are genuinely fine.

If you want to see what came out of following these steps, the [rate limiting post](/posts/dotnet7-how-to-use-rate-limitter/) is a good example of where the writing ended up, and [/projects](/projects/) has what I've actually built since.
