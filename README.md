# GAMA LLM Skill

This repository contains the source code for the LLM (Large Language Model) Skill for the GAMA platform. This skill allows GAMA agents to interact with large language models, enabling new kinds of agent behaviors and simulations.

## Prerequisites

Before you can build this project, you need to have the following software installed on your system:

*   **Java Development Kit (JDK)**: Version 21
*   **Apache Maven**: Version 3.9.x or higher

## Building the Plugin Locally

To build the GAMA plugin from the source code, follow these steps:

1.  **Clone the repository**:
    ```sh
    git clone https://github.com/hqnghi88/llm_skill.git
    cd llm_skill
    ```

2.  **Navigate to the parent maven project**:
    The build is orchestrated from the `llm.parent` directory.
    ```sh
    cd llm.parent
    ```

3.  **Run the build command**:
    Execute the following Maven command to build all the plugins and create the local p2 update site.
    ```sh
    mvn package
    ```

4.  **Locate the build artifacts**:
    After a successful build, the p2 update site will be generated in the following directory:
    `../llm.site/target/repository`

    A zipped version of the repository will also be available at:
    `../llm.site/target/llm.site-1.0.0-SNAPSHOT.zip` (The exact version number may vary).

## Installing the Plugin in GAMA

Once you have built the plugin, you can install it into your GAMA application using the local update site you created.

1.  Start GAMA.
2.  Go to the menu `Help` > `Install New Software...`.
3.  In the "Install" dialog, click the **Add...** button.
4.  In the "Add Repository" dialog, click the **Local...** button.
5.  Navigate to the directory where the p2 repository was generated (`.../llm.site/target/repository`) and select it.
6.  Give a name to the local repository (e.g., "GAMA LLM Skill - Local").
7.  Click **Add**.
8.  Back in the "Install" dialog, you should see the "LLM - GAMA's extension Site" category. Select it.
9.  Follow the on-screen instructions to complete the installation (accepting licenses, etc.).
10. Restart GAMA when prompted.

The LLM Skill should now be available in your GAMA installation.
