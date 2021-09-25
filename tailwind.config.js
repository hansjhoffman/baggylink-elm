module.exports = {
  mode: "jit",
  prefix: "tw-",
  purge: ["index.html", "./src/**/*.{elm,js,ts}"],
  darkMode: true,
  theme: {
    extend: {},
    fontFamily: {
      // https://fontjoy.com/
      sans: ["Fira Sans", "sans-serif"],
      serif: ["Merriweather", "serif"],
    },
  },
  variants: {
    extend: {},
  },
  plugins: [require("@tailwindcss/typography")],
};
