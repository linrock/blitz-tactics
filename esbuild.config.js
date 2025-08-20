const esbuild = require('esbuild')
const sassPlugin = require('esbuild-sass-plugin').sassPlugin
const vue3Plugin = require('esbuild-plugin-vue3')

const isProduction = process.env.NODE_ENV === 'production'
const isDevelopment = !isProduction

const buildOptions = {
  entryPoints: {
    'application': './app/javascript/application.ts',
    'bugsnag': './app/javascript/packs/bugsnag.ts'
  },
  bundle: true,
  sourcemap: isDevelopment,
  outdir: './app/assets/builds',
  publicPath: '/assets',
  minify: isProduction,
  target: ['es2020'],
  
  plugins: [
    vue3Plugin(),
    sassPlugin({
      // Process Sass files and emit CSS
      type: 'css',
      loadPaths: ['./app/assets/stylesheets', './node_modules']
    })
  ],
  
  loader: {
    '.png': 'file',
    '.jpg': 'file',
    '.jpeg': 'file',
    '.gif': 'file',
    '.svg': 'file',
    '.woff': 'file',
    '.woff2': 'file',
    '.ttf': 'file',
    '.eot': 'file'
  },
  
  define: {
    'process.env.NODE_ENV': JSON.stringify(process.env.NODE_ENV || 'development')
  },
  
  external: []
}

// Vue plugin is now configured above

module.exports = buildOptions

// Build function for programmatic usage
async function build() {
  try {
    const result = await esbuild.build(buildOptions)
    console.log('✅ Build completed successfully')
    return result
  } catch (error) {
    console.error('❌ Build failed:', error)
    process.exit(1)
  }
}

// Watch function for development
async function watch() {
  const ctx = await esbuild.context(buildOptions)
  await ctx.watch()
  console.log('👀 Watching for changes...')
}

// If called directly
if (require.main === module) {
  const command = process.argv[2]
  if (command === 'watch') {
    watch()
  } else {
    build()
  }
}

module.exports = { build, watch, buildOptions }
