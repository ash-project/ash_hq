// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

const plugin = require("tailwindcss/plugin")
const fs = require("fs")
const path = require("path")

module.exports = {
  darkMode: "class",
  content: [
    "./js/**/*.js",
    "../lib/*_web/**/*.*ex",
    "../lib/ash_hq/docs/extensions/**/*.*ex",
    "../priv/blog/**/*.md",
    "../deps/ash_authentication_phoenix/**/*.ex",
  ],
  theme: {
    extend: {
      animation: {
        'gradient': 'gradient 8s linear infinite',
        'float': 'float 7s ease-in-out infinite',
        'glow': 'glow 2s ease-in-out infinite alternate',
      },
      keyframes: {
        gradient: {
          '0%, 100%': {
            'background-size': '200% 200%',
            'background-position': 'left center'
          },
          '50%': {
            'background-size': '200% 200%',
            'background-position': 'right center'
          }
        },
        float: {
          '0%, 100%': { transform: 'translateY(0)' },
          '50%': { transform: 'translateY(-20px)' }
        },
        glow: {
          '0%': { 'box-shadow': '0 0 10px #FF5757' },
          '100%': { 'box-shadow': '0 0 20px #FF5757' }
        }
      },
      colors: {
        "silver-phoenix": "#EAEBF3",
        "base-dark": {
          "DEFAULT": "#5E627D",
          "50": "#C2C4D1",
          "100": "#B6B8C8",
          "200": "#9FA2B7",
          "300": "#878BA5",
          "400": "#707594",
          "500": "#5E627D",
          "600": "#46495D",
          "700": "#2E303D",
          "750": "#22242D",
          "800": "#16171D",
          "850": "#0c0c0f",
          "900": "#000000"
        },
        "base-light": {
          "DEFAULT": "#6b7280",
          "50": "#f9fafb",
          "100": "#f3f4f6",
          "200": "#e5e7eb",
          "300": "#d1d5db",
          "400": "#9ca3af",
          "500": "#6b7280",
          "600": "#4b5563",
          "700": "#374151",
          "800": "#1f2937",
          "900": "#111827"
        },
        "primary-dark": {
          "DEFAULT": "#FF5757",
          "50": "#FFE1E1",
          "100": "#FFD1D1",
          "200": "#FFB3B3",
          "300": "#FF9494",
          "400": "#FF7676",
          "500": "#FF5757",
          "600": "#FF1F1F",
          "700": "#E60000",
          "800": "#AE0000",
          "900": "#760000"
        },
        "primary-light": {
          "DEFAULT": "#FF914D",
          "50": "#FFE6D7",
          "100": "#FFDDC7",
          "200": "#FFCAA9",
          "300": "#FFB78A",
          "400": "#FFA46C",
          "500": "#FF914D",
          "600": "#FF6E15",
          "700": "#DC5400",
          "800": "#A43F00",
          "900": "#6C2900"
        }
      }
    }
  },
  plugins: [
    require("@tailwindcss/forms"),
    // Allows prefixing tailwind classes with LiveView classes to add rules
    // only when LiveView classes are applied, for example:
    //
    //     <div class="phx-click-loading:animate-ping">
    //
    plugin(({ addVariant }) => addVariant("phx-click-loading", [".phx-click-loading&", ".phx-click-loading &"])),
    plugin(({ addVariant }) => addVariant("phx-submit-loading", [".phx-submit-loading&", ".phx-submit-loading &"])),
    plugin(({ addVariant }) => addVariant("phx-change-loading", [".phx-change-loading&", ".phx-change-loading &"])),
    plugin(({ addVariant }) => addVariant("error", ["&.error", ".error &"])),

    // Embeds Heroicons (https://heroicons.com) into your app.css bundle
    // See your `CoreComponents.icon/1` for more information.
    //
    plugin(function ({ matchComponents, theme }) {
      let iconsDir = path.join(__dirname, "./vendor/heroicons/optimized")
      let values = {}
      let icons = [
        ["", "/24/outline"],
        ["-solid", "/24/solid"],
        ["-mini", "/20/solid"]
      ]
      icons.forEach(([suffix, dir]) => {
        fs.readdirSync(path.join(iconsDir, dir)).forEach(file => {
          let name = path.basename(file, ".svg") + suffix
          values[name] = { name, fullPath: path.join(iconsDir, dir, file) }
        })
      })
      matchComponents({
        "hero": ({ name, fullPath }) => {
          let content = fs.readFileSync(fullPath).toString().replace(/\r?\n|\r/g, "")
          return {
            [`--hero-${name}`]: `url('data:image/svg+xml;utf8,${content}')`,
            "-webkit-mask": `var(--hero-${name})`,
            "mask": `var(--hero-${name})`,
            "mask-repeat": "no-repeat",
            "background-color": "currentColor",
            "vertical-align": "middle",
            "display": "inline-block",
            "width": theme("spacing.5"),
            "height": theme("spacing.5")
          }
        }
      }, { values })
    })
  ]
}
