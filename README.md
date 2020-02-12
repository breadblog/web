# Bits n' Bites

[![Netlify Status](https://api.netlify.com/api/v1/badges/b14d6bfb-c76f-4064-9f38-cd35399b8c21/deploy-status)](https://app.netlify.com/sites/admiring-lalande-02829d/deploys)
![](https://github.com/BreadBlog/web/workflows/tests/badge.svg)

Bits n' Bites is our personal blog the two of us created together so we could share our thoughts with the world. If you like code, privacy, philosophy or food, you've come to the right place!

## Status

The project is currently under active development, and is not yet available for general use.

## Privacy

Privacy is something that's pretty important to us, and we feel that should be reflected in our blog as well. That's why the platform is open source, so you can plainly see what information we collect and what services we use. This section will be updated as we continue to work on the platform and its features.

### Netlify

We use netlify for building & hosting the web application. From what we could tell, they do not seem to collect information about their users unless you opt into using the form features (which we have not). If you are concerned about the use of Netlify's platform please open an issue or email us at blog@parasrah.com.

### Third party services

We are proud to say that currently, we are not using any third party services that might be sucking up your data (to the extent of our knowledge)

### API

We have actually developed our own API, and hosted it on a Raspberry PI swarm cluster inside our home. This is the very same API you can see [on github](https://github.com/BreadBlog/core), and is pulled directly from [docker hub](https://hub.docker.com/r/parasrah/blog-core). In the future we will be blogging about both the development of the API, and the setup of our cluster, so keep your eyes peeled for those posts.

## Security

As far as security is concerned, due to the nature of how the platform works at this point there is very little to worry about from a user perspective. All services are secured with TLS in transit, and all preferences etc are actually stored using localStorage in your browser. 

For those interested, the authors (currently just us) are protected using a variety of solutions, from `bcrypt` for password hashing, to `jwt` for session management. We actually implemented some extra measures around our use of `jwt` to acommodate for some of it's flaws, such as the inability to invalidate a session. We may release a blog post describing this in more detail, but of course the code is always yours to look at as well :octocat:

## Footnote

We hope you found what you came for, and that you enjoy the content we will be writing about in the future!

Brad & Bea (May 8, 2019)
