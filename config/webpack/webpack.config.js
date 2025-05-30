// See the shakacode/shakapacker README and docs directory for advice on customizing your webpackConfig.

const { generateWebpackConfig, config, merge } = require('shakapacker')
const webpackConfig = generateWebpackConfig()

const CompressionPlugin = require("compression-webpack-plugin");
const CssMinimizerPlugin = require("css-minimizer-webpack-plugin");
const MiniCssExtractPlugin = require("mini-css-extract-plugin");
const TerserPlugin = require("terser-webpack-plugin");
const { WebpackAssetsManifest } = require('webpack-assets-manifest');
const { SubresourceIntegrityPlugin } = require("webpack-subresource-integrity");

// This setting will change the absolute path used to refer
// external files (images, fonts, ...) in the generated assets
const relative_url_root = process.env.RAILS_RELATIVE_URL_ROOT || '';
const public_output_path = webpackConfig.output.publicPath;

const envConfig = module.exports = {
    node: {
        global: false,
    },
    module: {
        rules: [
            // Extract Bootstrap's inline SVGs to actual resources.
            // This removes the requirement for `data:` URLs in our CSP
            // See https://getbootstrap.com/docs/5.3/getting-started/webpack/#extracting-svg-files
            {
                mimetype: 'image/svg+xml',
                scheme: 'data',
                type: 'asset/resource',
                generator: {
                    filename: 'icons/[hash].svg'
                },
            },
            // Extract ToastUi's inline PNGs to actual resources, similar to Bootstrap's SVGs.
            // This removes the requirement for `data:` URLs in our CSP
            {
                mimetype: 'image/png',
                scheme: 'data',
                type: 'asset/resource',
                generator: {
                    filename: 'icons/[hash].png'
                },
            },
            {
                // Exclude non-JS file from select2-i18n, otherwise breaking our dynamic language lookup.
                test: /select2\/dist\/js\/i18n\/build\.txt$/,
                type: 'asset/resource',
                generator: {
                    emit: false,
                },
            },
        ]
    },
    optimization: {
        minimize: true,
        minimizer: [
            new TerserPlugin(),
            new CssMinimizerPlugin()
        ],
    },
    output: {
        publicPath: relative_url_root + public_output_path,
        // the following setting is required for SRI to work:
        crossOriginLoading: 'anonymous',
    },
    performance: {
        // Turn off size warnings for large assets
        hints: false
    },
    plugins: [
        new CompressionPlugin(),
        new MiniCssExtractPlugin({
            filename: '[name]-[contenthash].css',
        }),
        new SubresourceIntegrityPlugin(),
        new WebpackAssetsManifest({
            entrypoints: true,
            integrity: true,
            writeToDisk: true,
            entrypointsUseAssets: true,
            publicPath: true,
            output: config.manifestPath,
        })
    ],
    resolve: {
        extensions: ['.css', '.ts', '.tsx'],
        alias: {
            $: 'jquery/src/jquery',
            jquery: 'jquery/src/jquery',
        }
    },
    stats: 'minimal',
}

// Enable working source maps in development mode, overwriting the default 'cheap-module-source-map'.
if (webpackConfig.mode === 'development') {
    envConfig.devtool = 'source-map';
}

// Enable source map for SASS / SCSS files, including the original sources in the source map.
webpackConfig.module.rules
  .flatMap(rule => Array.isArray(rule.use) ? rule.use : [])
  .filter(loaderConfig => loaderConfig.options?.sassOptions)
  .forEach(loaderConfig => loaderConfig.options.sassOptions.sourceMapIncludeSources = true);

// Use the following lines below to remove original plugins and replace them with our custom config.
// This is especially needed for the `WebpackAssetsManifest` plugin, which would otherwise run twice.
const customPlugins = envConfig.plugins.map((plugin) => plugin.constructor.name);
const filteredDefaultPlugins = webpackConfig.plugins.filter((plugin) => {
    return !customPlugins.includes(plugin.constructor.name);
});
webpackConfig.plugins = filteredDefaultPlugins;

// Create the resulting config by merging the (modified) default config and our custom setup
module.exports = merge(webpackConfig, envConfig)
