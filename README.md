# PhxTailwindGenerators

**TODO: Add description**

    mix phx.gen.tailwind Blog Post posts title body:text

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

## Setup a fresh Phoenix System

This is a step by step howto to setup a Phoenix system with [Tailwind CSS](https://tailwindui.com). I didn't figure out anything of this by myself. It's all copy and paste.

### A fresh Phoenix application

We start with a fresh Phoenix setup:

````
$ mix phx.new example_shop
$ cd example_shop
$ mix ecto.create
````

#### Add PostCSS

````
$ cd assets
$ npm install tailwindcss postcss autoprefixer postcss-loader --save-dev
$ cd ..
````

Create the following file (with that content):

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

Here's the diff:
````
41a42
>             'postcss-loader',
````

#### Tailwind Configuration (Purge Unused Styles In Production)

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

Open **assets/css/app.scss** and replace the current content with this:

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

Feel free to test your new Tailwind setup by adding a `class="text-red-500"` to a `<p>` or `<h1>` element in `lib/example_shop_web/templates/page/index.html.eex` and watch it turn red.
