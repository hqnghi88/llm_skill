model SE_UseCase

global {
	string llmname <- "qwen3:30b";
	/*
	 * 
planner = Agent("Planner", llm)
coder = Agent("Coder", llm)
critic = Agent("Critic", llm)

task = planner.plan("Build offline GIS simulation app")

code = coder.execute(task)
review = critic.review(code)

if review.bad:
    coder.fix(review)
	 */
	string create_agent (string msg) {
		write "==========";
		write "SUB AGENT";
		write "==========" + msg;
		string res <- "";
		create AI_Agent {
			llm <- create_ollama_chat_model(url: "http://localhost:11434", model_name: "gpt-4o-mini:latest");
			chat_memory <- create_chat_memory(llm, msg);
			chat_bot <- create_assistant(llm: llm, memory: chat_memory, tool_provider: tool);
			mymsg <- user_goal + mymsg;
			write "==========CREATED";
			res <- "" + int(self);
			AI_Manager[0].worker << self;
		}

		return res;
	}

	string asking (string msg) {
		write "==========";
		write "ASKING AGENT";
		write "==========";
		//			}
		ask AI_Agent {
			string ms <- send_to_llm(llm, msg + ". Return only the result, no explanation, no reasoning", true, true);
			msg <- ms;
		}

		write msg;
		write "==========";
		write "END ASKING";
		write "==========";
		return msg;
	}

	string save_file (string content, string fpath) {
		try {
			write "save tool: ";
			write content;
			write " to " + fpath;
			save content to: fpath format: "text";
			return "saved to " + fpath;
		}

		catch {
			write #current_error;
			return "error";
		}

	}

	string compile_file (string file_path) {
		try {
			write ">>>>>>>compile tool: " + file_path;
			string cmd1 <- "javac  " + file_path;
			string res <- command(cmd1);
			write "command return: " + res;
			return "compiled with message:" + res;
		}

		catch {
			write #current_error;
			return "error";
		}

	}

	string roleMsg <- '
You are the ORCHESTRATOR of a multi-agent LLM system.

You do NOT solve the task directly.

Instead, you MUST:
1. Create specialized agents using the `create_agent` tool
2. Delegate work to them
3. Collect their outputs
4. Decide the final result

--------------------------------------------------
AVAILABLE TOOL

create_agent( 
  system_prompt: string, 
) -> AgentID
this tool return the id of agent created and take its system prompt as parameter
--------------------------------------------------

AGENT TYPES TO CREATE (REQUIRED):

1. PLANNER
   Role: Task decomposition and sequencing
   Responsibilities:
   - Break the user goal into ordered tasks
   - Assign tasks to other agents
   Constraints:
   - No implementation details

2. RESEARCHER
   Role: Grounding and constraints
   Responsibilities:
   - Provide factual constraints and assumptions
   - Identify unknowns and risks
   Constraints:
   - No design or code

3. ARCHITECT
   Role: System design
   Responsibilities:
   - Propose architecture and data flow
   - Explain trade-offs
   Constraints:
   - No low-level code

4. CODER
   Role: Implementation
   Responsibilities:
   - Produce minimal runnable code or pseudocode
   Constraints:
   - Follow architect decisions strictly

5. CRITIC
   Role: Quality and correctness
   Responsibilities:
   - Identify flaws, edge cases, missing parts
   Constraints:
   - Must be strict and technical

6. MANAGER
   Role: Final decision
   Responsibilities:
   - Decide whether output meets the goal
   - Request ONE revision if needed
   - Produce final answer
   Constraints:
   - No new content creation

--------------------------------------------------
EXECUTION RULES

- You MUST call `create_agent` once for EACH agent above.
- You MUST execute agents in this order:
  PLANNER → RESEARCHER → ARCHITECT → CODER → CRITIC → MANAGER
- Agents may only see outputs from previous agents.
- CRITIC must always attempt to find problems.
- MANAGER may trigger ONE revision cycle:
  CODER → CRITIC → MANAGER
- Keep everything minimal and practical.
- Do NOT expose hidden chain-of-thought.
- Always label outputs clearly.

--------------------------------------------------
OUTPUT FORMAT

[AGENT: PLANNER]
...

[AGENT: RESEARCHER]
...

[AGENT: ARCHITECT]
...

[AGENT: CODER]
...

[AGENT: CRITIC]
...

[AGENT: MANAGER – FINAL ANSWER]
...

-------------------------------------------------- 
...


';
	string user_goal <- "USER GOAL: Build a minimal local-only multi-agent system that answers questions using a local knowledge base (KMS-first, no cloud).";

	init {
		create AI_Manager {
			llm <- create_ollama_chat_model(url: "http://localhost:11434", model_name: llmname);
			chat_memory <- create_chat_memory(llm, roleMsg);
			tool <- create_tool_executor_from_json(json: '{
				  "name": "create_agent",
				  "description": "create the AI sub agent when manager ai call the function",
				  "parameters": {
				    "type": "object",
				    "properties": {
				      "msg": {
				        "type": "string",
				        "description": "The system prompt message of the agent"
				      } 
				    },
				    "required": []
				  }
				}', execute: world.create_agent);
			tool <- add_tool_executor_from_json(provider: tool, json: '{
				  "name": "asking",
				  "description": "this will ask the agent to do task and return result",
				  "parameters": {
				    "type": "object",
				    "properties": {
				      "msg": {
				        "type": "string",
				        "description": "The message to ask the agent to do"
				      } 
				    },
				    "required": [
				      "msg"
				    ]
				  }
				}', execute: world.asking);
			tool <- add_tool_executor_from_json(provider: tool, json: '{
				  "name": "save",
				  "description": "it will create a file on disk, extension java, the file name must correspond with the java class",
				  "parameters": {
				    "type": "object",
				    "properties": {
				      "content": {
				        "type": "string",
				        "description": "The content to save to file on disk"
				      } ,
				      "fpath": {
				        "type": "string",
				        "description": "The file path to save on disk"
				      } 
				    },
				    "required": [
				      "content","fpath"
				    ]
				  }
				}', execute: world.save_file);
			tool <- add_tool_executor_from_json(provider: tool, json: '{
				  "name": "compile",
				  "description": "it will compile with javac to get the bytecode of that java class",
				  "parameters": {
				    "type": "object",
				    "properties": {
				      "file_path": {
				        "type": "string",
				        "description": "The file path of text code to be compiled with javac"
				      } 
				    },
				    "required": [
				      "file_path"
				    ]
				  }
				}', execute: world.compile_file);
			chat_bot <- create_assistant(llm: llm, memory: chat_memory, tool_provider: tool);
			//			mymsg <- send_to_assistant(assistant: chat_bot, message: "build an java app to get an array of integer from user, sort it in asc and print the result out");
			mymsg <- send_to_assistant(assistant: chat_bot, message: user_goal);
			write mymsg;
		} } }

species AI_Agent skills: [llm] {
	mcp_transport transport;
	mcp_client client;
	tool_provider tool;
	string mymsg <- "do your job";

	reflex chating {
		do add_to_memory message: mymsg memory: chat_memory;
		mymsg <- send_to_assistant(assistant: chat_bot, message: mymsg);
		write mymsg;
		do add_to_memory message: mymsg memory: chat_memory;
	}

	aspect default {
		draw circle(5) color: #red;
	} }

species AI_Manager skills: [llm] {
	mcp_transport transport;
	mcp_client client;
	tool_provider tool;
	string mymsg;
	list<agent> worker;

	reflex chating {
		do add_to_memory message: mymsg memory: chat_memory;
		mymsg <- send_to_assistant(assistant: chat_bot, message: mymsg);
		write mymsg;
		do add_to_memory message: mymsg memory: chat_memory;
	} }

experiment "main" type: gui {
	output {
	}

}
