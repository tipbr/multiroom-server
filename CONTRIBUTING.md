# Contributing to Multiroom Server

Thank you for your interest in contributing to the Multiroom Audio Server project!

## How to Contribute

### Reporting Issues

If you encounter a bug or have a feature request:

1. Check if the issue already exists in the [GitHub Issues](https://github.com/tipbr/multiroom-server/issues)
2. If not, create a new issue with:
   - A clear, descriptive title
   - Detailed description of the issue or feature
   - Steps to reproduce (for bugs)
   - Your environment details (OS, Docker version, etc.)
   - Any relevant logs or screenshots

### Pull Requests

We welcome pull requests! Here's how to submit one:

1. **Fork the repository** and create your branch from `main`
2. **Make your changes**:
   - Keep changes focused and minimal
   - Follow the existing code style
   - Update documentation if needed
3. **Test your changes**:
   - Build the Docker image: `docker-compose build`
   - Run the container: `docker-compose up`
   - Verify functionality works as expected
4. **Commit your changes**:
   - Use clear, descriptive commit messages
   - Reference any related issues
5. **Push to your fork** and submit a pull request

### Development Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/tipbr/multiroom-server.git
   cd multiroom-server
   ```

2. Build the Docker image:
   ```bash
   docker-compose build
   ```

3. Run the server:
   ```bash
   docker-compose up
   ```

4. Access the web interface at `http://localhost:1780`

### Adding New Features

When adding new streaming protocols or features:

1. **Update the Dockerfile** to include necessary packages
2. **Configure the audio pipeline** to output to a named pipe
3. **Update snapserver.conf** to add the new audio source
4. **Add Avahi service files** if mDNS discovery is needed
5. **Update documentation** in README.md
6. **Add client examples** if applicable in the `clients/` directory

### Code Style

- Use clear, descriptive variable names
- Comment complex configurations
- Keep shell scripts POSIX-compliant where possible
- Format YAML and configuration files consistently

### Testing

Before submitting a PR, please test:

1. **Docker build**: `docker-compose build` completes successfully
2. **Container startup**: Services start without errors
3. **Functionality**: Each audio source works as expected
4. **Client connections**: Clients can connect and play audio
5. **Web interface**: The Snapcast web UI is accessible

### Documentation

Good documentation is crucial. When adding features:

- Update the main README.md
- Add examples to the `clients/` directory if relevant
- Include configuration file examples
- Document any new environment variables or options
- Add troubleshooting tips if applicable

## Questions?

If you have questions about contributing, feel free to:
- Open an issue for discussion
- Reach out to the maintainers

Thank you for contributing! 🎵
