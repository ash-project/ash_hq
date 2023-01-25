const colors = require("tailwindcss/colors");

module.exports = {
  mode: "jit",
  content: [
    "./js/**/*.js", 
    "../lib/*_web/**/*.*ex", 
    "../deps/sunflower_ui/**/*.ex", 
    "../priv/blog/**/*.md", 
    "../deps/ash_authentication_phoenix/**/*.ex"
  ],
  darkMode: "class",
  theme: {
    extend: {
      typography: {
        DEFAULT: {
          css: {
            "code::before": {
              content: '""',
            },
            "code::after": {
              content: '""',
            },
          },
        },
      },
      colors: require("./tailwind.colors.json")
    },
  },
  variants: {
    extend: {
      display: ["dark"],
    },
  },
  plugins: [
    require("@tailwindcss/typography"),
    require("@tailwindcss/forms"),
    require("@tailwindcss/line-clamp"),
  ],
  safelist: [
    // Used in Table of Contents generation, which is stored in the DB and cannot be
    // checked at build time.
    "m-0",
    "md:w-[20em]",
    "md:p-4",
    "md:float-right",
    "list-[lower-alpha]",
    "md:border",
    "md:border-base-light-300",
    "md:dark:border-base-dark-600",
    "md:ml-8",
    "md:mb-8",
    "text-ellipsis",
    "overflow-hidden",
  ],
};
