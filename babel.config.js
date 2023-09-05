module.exports = {
  presets: ['@babel/preset-typescript', '@babel/preset-env', '@babel/preset-react'],
  plugins: [
    ['@babel/plugin-transform-typescript', { allowDeclareFields: true }],
    '@babel/plugin-proposal-class-properties'
  ],
  compact: false,
  comments: false,
  exclude: 'node_modules/**'
};
