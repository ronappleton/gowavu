module.exports = {
    branches: ['master'],
    plugins: [
        '@semantic-release/commit-analyzer',
        '@semantic-release/release-notes-generator',
        '@semantic-release/changelog',
        '@semantic-release/npm',
        '@semantic-release/github',
        [
            '@semantic-release/git',
            {
                assets: ['package.json', 'CHANGELOG.md'],
                message: 'chore(release): ${nextRelease.version} [skip ci]\n\n${nextRelease.notes}',
            },
        ],
    ],
    "devDependencies": {
        "semantic-release": "^19.0.0",
        "@semantic-release/changelog": "^6.0.0",
        "@semantic-release/git": "^10.0.0",
        "@semantic-release/github": "^8.0.0",
        "@semantic-release/commit-analyzer": "^9.0.0",
        "@semantic-release/release-notes-generator": "^10.0.0",
        "@semantic-release/npm": "^8.0.0"
    },
    "engines": {
        "node": ">=16.0.0"
    }
};