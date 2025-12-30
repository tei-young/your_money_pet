import type { Config } from "tailwindcss";

export default {
  darkMode: ["class"],
  content: [
    "./pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./components/**/*.{js,ts,jsx,tsx,mdx}",
    "./app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          DEFAULT: "#9F7AEA",
          light: "#D6BCFA",
          pale: "#F3E8FF",
        },
        safe: "#718096",
        balanced: "#B794F6",
        aggressive: "#9F7AEA",
        challenger: "#4A5568",
      },
    },
  },
  plugins: [],
} satisfies Config;
