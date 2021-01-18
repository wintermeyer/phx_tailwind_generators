# PhxTailwindGenerators

A scaffold generator for new resources which uses [Tailwind CSS](https://tailwindui.com) and not the default [Milligram](https://milligram.io).

If you already have a Tailwind system up and running within your Phoenix application than you just have to add `{:phx_tailwind_generators, "~> 0.1.0"}` to your `mix.exs` and run a `mix deps.get` to get access to the `mix phx.gen.tailwind Blog Post posts title body:text` generator.

If you don't have a Tailwind setup yet ... I have you covered. And yes, you can use this Howto even if you don't want to use the generator.

## Setup Phoenix with Tailwind

A step by step howto to setup a Phoenix system with [Tailwind CSS](https://tailwindui.com). When useful I use the output of [diff](https://en.wikipedia.org/wiki/Diff) to describe where to include/change code (the first number is the line number). 

I promise to not use "this is easy". Nothing is easy if you don't know how to do it.

### A green field

We start with a fresh Phoenix application named `example_shop`:

````
$ mix phx.new example_shop
$ cd example_shop
$ mix ecto.create
````

### Add PostCSS

[PostCSS](https://postcss.org) is a tool for transforming CSS with JavaScript.

````
$ cd assets
$ npm install tailwindcss postcss autoprefixer postcss-loader --save-dev
$ cd ..
````

Create the following file with this content:

**assets/postcss.config.js**
````
module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  }
}
````

Open the file **assets/webpack.config.js** in the 
editor of your choice. Search for `sass-loader` and add `'postcss-loader',` before it.

The diff:
````
41a42
>             'postcss-loader',
````

### Purge unused styles in production

This makes for a minimal CSS file in your production environment. This results in a better WebPerformance.

````
$ cd assets
$ npx tailwind init
$ cd ..
````

Open the file **assets/tailwind.config.js** with an editor and change it according this diff:

````
2c2,8
<   purge: [],
---
>   purge: [
>     "../**/*.html.eex",
>     "../**/*.html.leex",
>     "../**/views/**/*.ex",
>     "../**/live/**/*.ex",
>     "./js/**/*.js",
>   ],
````

Do this change in **assets/package.json**

````
6c6
<     "deploy": "webpack --mode production",
---
>     "deploy": "NODE_ENV=production webpack --mode production",
````

Replace **assets/css/app.scss** with this code:

````
/* This file is for your main application css. */
@tailwind base;
@tailwind components;
@tailwind utilities;
````

Remove the not needed default Phoenix CSS:

````
$ rm assets/css/phoenix.css 
````

**Now you have a running Tailwind CSS system within your Phoenix application!**

The test: Fire up your Phoenix application with `mix phx.server` and open http://localhost:4000 with your browser. Open `lib/example_shop_web/templates/page/index.html.eex` in your editor and search for a `<h1>` or `<p>` element. Add `class="text-red-500"` to it and watch it turn red in your browser.

### Add CSS for the forms

We are not 100% there yet because we need some extra CSS for forms. But that is done in two steps:

````
$ cd assets
$ npm install @tailwindcss/forms
$ cd ..
````

Change **assets/tailwind.config.js** according to this diff. 

````
16,17c16,19
<   plugins: [],
< }
---
>   plugins: [
>     require('@tailwindcss/forms'),
>   ],
> };
````

Now you can install the generator.

## Installation of the generator

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `phx_tailwind_generators` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:phx_tailwind_generators, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/phx_tailwind_generators](https://hexdocs.pm/phx_tailwind_generators).

## Use of the generator

The generator works like the default scaffold generator. Only the name is different:

````
mix phx.gen.tailwind Blog Post posts title body:text
````

This will create templates which use Tailwind CSS. Have fun with it.

Please do submit bugs or better create pull requests!

## Bonus: Install Alpine

Since you are now using Phoenix with Tailwind the chances are high that 
you want to use [Alpine.js](https://github.com/alpinejs/alpine) too. Follow me.

````
$ cd assets
$ npm install alpinejs
$ cd ..
````

Open **assets/js/app.js** in your editor and add these lines to the bottom:

````
let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")

// Alpinejs
import Alpine from "alpinejs"
let liveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrfToken },
  dom: {
    onBeforeElUpdated(from, to) {
      if (from.__x) { Alpine.clone(from.__x, to) }
    }
  }
})
````

You can test your new setup with this example code. Just place it in  `lib/example_shop_web/templates/page/index.html.eex` and click on the blue button.

````
<div x-data="{ open: false }">
    <button @click="open = true" class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500">Open Dropdown</button>

    <ul
        x-show="open"
        @click.away="open = false"
    >
        Dropdown Body
    </ul>
</div>
````

## Acknowledgments

Very little in this repository was created by me. Most of this is copy and pasted from other resources. And the whole mix package wouldn't exist without the help of [James Edward Gray II](https://twitter.com/jeg2) who walked me through the steps of creating it.

Resources I used:

- [Adding Tailwind CSS to Phoenix 1.4 and 1.5](https://pragmaticstudio.com/tutorials/adding-tailwind-css-to-phoenix)
- [Phoenix 1.5 with Tailwind](https://sisccr.medium.com/phoenix-1-5-with-tailwind-4030198bf7c7)
- [Combine Phoenix LiveView with Alpine.js](https://fullstackphoenix.com/tutorials/combine-phoenix-liveview-with-alpine-js)
- [Optimizing User Experience with LiveView](https://dockyard.com/blog/2020/12/21/optimizing-user-experience-with-liveview)