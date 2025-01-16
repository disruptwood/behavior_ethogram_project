
This project processes behavioral data from flies, stored in .mat files. 
It merges data across conditions, computes metrics about representativeness, 
and generates ethograms (visualizations of behaviors over time) for one or multiple flies.

Users can select whether they want a single fly ethogram, or a group ethogram. 
The project also calculates how “representative” a fly is relative to the group and can sort flies accordingly.


HOW TO USE THIS PROJECT

1. Run the GUI:
   - Open MATLAB.
   - Run gui_main.m from the project’s scripts folder.
   - A file selection window opens. You can select:
     - One or more .mat files (single condition).
     - One or more folders each containing .mat files named scores_.mat (multiple conditions).
   - After file selection, a menu appears with choices:
     - Single Fly Ethogram: Generates a simple ethogram for a single fly. You can pick which fly to analyze.
     - Group Ethogram: Combines and visualizes behaviors for multiple flies simultaneously. You can specify how many of the most representative flies to include.
     - Check Representativeness: list flies sorted by how closely they match the group’s average behavior

2. Explore the Outputs:
   - Ethograms are saved in figures. 
   - Check the MATLAB console for textual outputs (like which flies are most representative).


EXECUTION SEQUENCE AND FUNCTION LOGIC

The functions are listed in the order they run when the user starts at gui_main.m:

1) gui_main()
   - Inputs: None directly from the user; it’s the main script.
   - Outputs: No direct return value, but it triggers the rest of the workflow.
   - Logic:
     - Adds all subfolders to the MATLAB path (calls add_project_paths()).
     - Opens a file/folder selection dialog (calls extractFilesAndLabels(), which internally calls selectFilesOrFolders()).
     - Loads and merges behavior data (calls extract_behavior_data_group()).
     - Displays a menu to choose one of several tasks:
       - Single Fly Ethogram
       - Group Ethogram
       - Check Representativeness
     - Depending on the selection:
       - For single fly: prompts user for a fly index and optionally calls compute_fly_representativeness() if the user picks “most representative,” then calls get_single_fly_data() and a plotting function (create_heatmap_single_ethogram()).
       - For group ethogram: calls getNumFliesToAnalyze(), calls compute_fly_representativeness(), then calls create_group_ethogram().
       - For representativeness checking: calls compute_fly_representativeness() and prints the ranking.

2) add_project_paths()
   - Inputs: None. Uses the current working directory.
   - Outputs: No explicit return. Modifies the MATLAB path so all subfolders are accessible.
   - Logic: Recursively scans the current folder, adds all subdirectories to the path.

3) extractFilesAndLabels()
   - Inputs: None directly. Invokes selectFilesOrFolders() inside it.
   - Outputs:
     - filesNames: A list of .mat file paths.
     - numFlies: Number of flies found in the first .mat file.
     - folderTags: Labels for each file’s folder (used if multiple conditions).
   - Logic:
     - Calls selectFilesOrFolders() to let the user pick .mat files or folders.
     - If files were chosen, treats them all as one condition.
     - If folders were chosen, searches each folder (and subfolders) for files matching scores_.mat.
     - Loads the first .mat file to see how many flies are in it.
     - Detects different conditions by this folders.
     - Returns the list of files, number of flies, and folder tags.

4) selectFilesOrFolders()
   - Inputs: None. Just presents a dialog box.
   - Outputs:
     - selectedPaths: Cell array of chosen file or folder paths.
     - selectionType: Either 'files' or 'folders'.
   - Logic:
     - Uses a Java-based file chooser that allows multiple selections.
     - Restricts to either all .mat files or all folders, not a mix.
     - Returns the chosen paths plus a string telling the type of selection.

5) extract_behavior_data_group()
   - Inputs:
     - filesNames: Cell array of .mat paths.
     - folderTags: Condition labels (empty if single condition).
   - Outputs:
     - behaviorData: A struct where each field is a [numFlies x numFrames] binary matrix for a behavior.
     - behaviorLabels: The final ordered list of all behaviors found.
     - conditionLabels: The condition/folder tag for each fly’s row.
     - localIndices: Each fly’s index within its local folder.
     - minFrames: The smallest frame count across all files.
   - Logic:
     - Finds the minimum number of frames across all selected .mat files.
     - For each condition, loads .mat files, extracts the “postprocessed” data, and pads or truncates it to minFrames.
     - Merges everything into a single big struct with one row per fly.
     - Calls getPredefinedOrder() to reorder certain known behaviors first.

6) getPredefinedOrder()
   - Inputs: None.
   - Outputs: A predefined cell REVERSED array listing behaviors in a certain recommended order (e.g., “Jump”, “Grooming”, etc.).
   - Logic: Contains a hard-coded list to standardize ordering.

7) compute_fly_representativeness()
   - Inputs:
     - behaviorData: Merged struct with all behaviors in [numFlies x numFrames].
     - minFrames: The frame count used for all data.
     - maxFlies: Optional limit on how many flies to consider if testing.
   - Outputs:
     - sortedFlyIndices: Sorted global fly indices by descending representativeness.
     - sortedScores: Representativeness scores (0–100).
     - groupSimilarity: Average representativeness for the entire set.
   - Logic:
     - Keeps only certain key behaviors (Walk, Stop, Turn, Touch, Grooming).
     - Builds a 3D array [behavior x fly x frame].
     - Calculates each fly’s distance to the group average, applying higher weights to moderately frequent behaviors, ignoring extremely rare ones.
     - Converts distance into a representativeness percentage.
     - Sorts flies in descending order of representativeness.
     - Returns the sorted list and an overall average.

8) getFlyIndex()
   - Inputs: The total number of flies in the dataset.
   - Outputs: The user’s chosen fly index (or zero if they want the most representative).
   - Logic: Asks the user via a dialog for a numeric input; checks validity.

9) getNumFliesToAnalyze()
   - Inputs: A suggested maximum number (e.g., 10).
   - Outputs: The user’s chosen number of flies to include in the group plot.
   - Logic: Asks the user for a value; returns that or total if 0.

10) get_single_fly_data()
    - Inputs:
      - mergedData: The big struct of [numFlies x numFrames] per behavior.
      - behaviorLabels: The ordered behaviors to extract.
      - flyIdx: Which fly to extract.
    - Outputs:
      - A struct where each field is [1 x numFrames] binary data for that chosen fly.
    - Logic:
      - Reads one row from each behavior’s matrix.
      - Returns a smaller struct for just that fly.

11) create_heatmap_single_ethogram()
    - Inputs:
      - behaviorData: A struct with single-fly arrays [1 x numFrames] or a subset from get_single_fly_data().
      - flyIndex: The selected fly’s index (for labeling the figure).
      - behaviorLabels: The behaviors in row order.
    - Outputs: No direct return; produces a figure with a heatmap.
    - Logic:
      - Builds an RGB array where each row is a behavior and each column is a frame.
      - Colors cells where a behavior is active, leaves the rest white.
      - Sets up axes in minutes (assuming 30 frames/sec).
      - Displays the figure.

12) create_group_ethogram()
    - Inputs:
      - behaviorData: Struct with [numFlies x numFrames] data per behavior.
      - behaviorLabels: Behavior names in the desired order.
      - minFrames: The number of frames for all data.
      - selectedFlyIndices: Which flies to include in the group.
    - Outputs: No direct return; creates a figure showing aggregated behavior usage.
    - Logic:
      - Calculates the proportion of flies doing each behavior at each frame.
      - Maps that to a color (the behavior’s designated color) and a transparency level based on fraction active.
      - Plots this as an image so darker or more opaque cells mean a higher fraction of flies are doing that behavior.

List of proposed improvements:

1. Customizing Ethogram Design  
   - Introduce user-definable color palettes and layout schemes.
   - Allow toggling between different visual representations (e.g., bars, layered overlays).
   - Provide options to highlight rare or high-frequency behaviors.

2. Refining Representativeness Assessment  
   - Clearly document how representativeness scores are calculated.
   - Implement parameters (e.g., behavior rarity thresholds) that can be adjusted to fine-tune scoring.
   - Let users choose from multiple weighting strategies depending on data characteristics.

3. Updating the Interface  
   - Add tabbed sections for different ethogram types and data views.
   - Improve file selection dialogs to show file metadata (number of flies, frames).
   - Provide context-sensitive help pop-ups that explain each major step.

4. Identifying Edge Cases  
   - Handle scenarios where no valid data is found in the selected .mat files.
   - Ensure robust merging of partial or uneven .mat files (different frame lengths).
   - Warn if the user picks contradictory data sources (e.g., mixing different sampling rates).

5. Exploring Alternative Representativeness Metrics  
   - Compare different distance measures (e.g., cosine similarity, Jaccard index).
   - Implement a function to plot how each metric influences the fly rankings.
   - Let advanced users plug in custom formulas to compute representativeness.