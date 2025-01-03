---
title: Starting A Blog Hosted On Github Pages
date: 2024-07-09 22:37 +0300
categories: [Ruby, Jekyll]
tags: [Blog, Tutorial, Ruby, Jekyll, Github]
---

## My First Ever Blog Post
I've been thinking about starting a blog for a while now and I was procrastinating quite a bit. But, I finally did it and here I am writing my first ever blog post. Suprisingly enough, it will be about my experience setting up my blog and how you can do it too.

![Desktop View](/assets/img/posts/blog_meme.jpg)
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
    - Make sure to name it as `<your-gh-username>.github.io`
    - After doing this step Github actions will build and deploy your blog automatically to `<your-gh-username>.github.io`
    - But you don't want just a template, you want to customized it to yourself. So, let's move on to the next step.
2. Clone the repository you just created.
3. Install Ruby and Jekyll on your machine through the [official guide](https://jekyllrb.com/docs/installation/).
4. Run `bundle install` to install the required gems.
5. Update the variables of `_config.yml` as needed. Some of them are typical options.
    - `url` is the address of your website
    - `avatar` is the profile picture in the sidebar
    - `timezone` is used to display the date and time of your posts
    - `lang` is the language of the site
6. Run `bundle exec jekyll s` to start the local server.

![Template Blog](/assets/img/posts/template-blog.png)
_The original template you should see_

If you face any issues, you can refer to the [Chripy theme's Getting started guide](https://chirpy.cotes.page/posts/getting-started/).

## Step 3: Setup Your Custom Root Domain

You need to visit one of the domain name registrar to buy a custom domain. There are multiple registrars to choose from: 

* [GoDaddy](https://www.godaddy.com/)
* [Google Domains](https://domains.google)
* [Name Cheap](https://www.namecheap.com/)

### Configure Your Domain

After you purchase your domain, go into your domain management portal, click on manage DNS and add `A` type DNS records for github pages.

| Type | Data |
|------|------|
| A | 185.199.108.153 |
| A | 185.199.109.153 |
| A | 185.199.110.153 |
| A | 185.199.111.153 |
| CNAME | gh-username.github.io |

*(These `A` type DNS records map your domain name to the Github's IP address)*

### Configure Github Pages

Now that you have your domain's DNS setup, Let's head back to Github and configure your Github Pages to use your custom domain.

1. Go to your **repository's settings** page.
2. Scroll down to the **Pages** section.
3. Under **Custom domain** enter your domain name and click **Save**.

![Custom Domain](/assets/img/posts/custom-domain.PNG)
_My Github Pages Custom Domain page_

***Best Practice :*** Click on **Enforce HTTPS** to serve your blog via secure SSL connection. Your site will be configured with a free SSL certificate from [Let's Encrypt](https://letsencrypt.org/).

Hope you found this article useful. If you have any questions, you can check my [blog's repo](https://github.com/alparslanakbas/alparslanakbas.github.io) on Github or feel free to reach out to me on [LinkedIn](https://www.linkedin.com/in/alparslanakbas/).