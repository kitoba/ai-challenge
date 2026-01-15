import esbuild from "esbuild";
esbuild.build({
  entryPoints: ["src/index.ts"],
  platform: "node",
  bundle: true,
  outfile: "dist/index.js",
  sourcemap: true,
  minify: false,
  define: {
  },
});
