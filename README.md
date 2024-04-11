
# Using Ganache with Truffle

This guide provides step-by-step instructions on how to clone an existing Truffle project and open its configuration (`truffle-config.js`) file in Ganache.

## Prerequisites

- [Truffle](https://www.trufflesuite.com/docs/truffle/getting-started/installation) installed (`npm install -g truffle`)
- [Ganache](https://www.trufflesuite.com/docs/ganache/quickstart) application installed
- [Git](https://git-scm.com/) installed for cloning the project repository

## Steps

### 1. Clone the Truffle Project

1. **Clone the repository**:
    - Open a terminal window.
    - Run the following command to clone the project repository:
    
    ```bash
    git clone https://github.com/vanessaachristy/mymedtrust.git
    ```

2. **Navigate to the project directory**:
    - After cloning the repository, navigate to the project's root directory:

    ```bash
    cd your-repository
    ```

### 2. Install Project Dependencies

- **Install dependencies**:
    - Once you are in the project directory, install the project's dependencies:

    ```bash
    npm install
    ```

### 3. Start Ganache

1. **Launch Ganache**:
    - Open the Ganache application on your system.
    - If you haven't already created a workspace, you will be prompted to create one.

### 4. Configure Workspace

1. **Project**:
    - In Ganache, click the "New Workspace" button if needed.
    - In the "Project" section, click "Add Project."
    - Navigate to the directory of your existing Truffle project and select the `truffle-config.js` file.
    - Click "Open" to add the project.

2. **Server**:
    - Ensure the network settings in Ganache match those in the `truffle-config.js` file.
    - Typically, set the host to `127.0.0.1`, and the port to `7545`.
    - Make sure the network ID matches the configuration in your project (usually `*`).

3. **Save Workspace**:
    - Once you have set up your workspace with your Truffle project, click "Save Workspace" in the top-right corner.

### 5. Interact with Ganache

1. **Access Accounts**:
    - Ganache provides a list of accounts you can use in your Truffle project for testing and development.

2. **Deploy Contracts**:
    - In your project directory, run the following command to deploy your smart contracts to the local blockchain:

    ```bash
    truffle migrate
    ```

3. **Truffle Console**:
    - Open the Truffle console to interact with your contracts:

    ```bash
    truffle console
    ```

### 6. Additional Tips

- **Synchronize your configuration**: Ensure your `truffle-config.js` file and Ganache workspace are configured to use the same host, port, and network ID for smooth interaction.
- **Testing and Debugging**: Use Ganache for testing and debugging your smart contracts within a controlled, local blockchain environment.
