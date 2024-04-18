const test = (r) => r.test.bind(r);

module.exports = {
  defaultIgnores: false,
  extends: ['@commitlint/config-conventional'],
  ignores: [test(/Merge branch (.*?)(in|into) (.*)/)],
};
