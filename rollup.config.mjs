//rollup-plugin-commonjs rollup-plugin-json rollup-plugin-node-resolve rollup-plugin-typescript rollup-plugin-terser rollup-plugin-license

import commonjs from '@rollup/plugin-commonjs';
import json from '@rollup/plugin-json';
import resolve from '@rollup/plugin-node-resolve';
import postcss from 'rollup-plugin-postcss';
import { babel } from '@rollup/plugin-babel';
import externals from 'rollup-plugin-node-externals';
import typescript from 'rollup-plugin-typescript2';

const settings = {
  globals: {
    ms: 'ms'
  }
};

export default {
  input: './lib/index.ts',

  output: [
    {
      ...settings
    }
  ],
  plugins: [
    externals({
      devDeps: true,
    }),
    babel({ rootMode: 'upward' }),
    postcss({
      minimize: false,
      extract: true
    }),
    resolve({}),
    commonjs({}),
    json()
  ]
};
