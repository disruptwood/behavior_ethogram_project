function [selectedPaths, selectionType] = selectFilesOrFolders()
  % selectFilesOrFolders: Opens a dialog to select multiple .mat files or folders.
    % Automatically starts in the same directory as this .m file (project root).
    %
    % Returns:
    %   selectedPaths - Cell array of selected file or folder paths.
    %   selectionType - 'files' or 'folders' indicating the selection type.

    import javax.swing.JFileChooser;
    import javax.swing.filechooser.FileSystemView;

    % Use current working directory as the starting point
    initialDir = pwd;

    % Initialize JFileChooser to start in projectRoot
    chooser = JFileChooser(initialDir);
    %chooser = JFileChooser(FileSystemView.getFileSystemView());
    chooser.setMultiSelectionEnabled(true);
    chooser.setFileSelectionMode(JFileChooser.FILES_AND_DIRECTORIES);
    chooser.setDialogTitle('Select Files or Folders');

    % Show the dialog
    status = chooser.showOpenDialog([]);
    if status ~= JFileChooser.APPROVE_OPTION
        selectedPaths = {};
        selectionType = '';
        return;
    end

    % Get selected files and directories
    selections = chooser.getSelectedFiles();
    selectedPaths = cell(1, length(selections));
    for i = 1:length(selections)
        selectedPaths{i} = char(selections(i).getAbsolutePath());
    end

    % Filter to only .mat files or directories
    selectedPaths = selectedPaths(cellfun(@(p) isfolder(p) || endsWith(p, '.mat'), selectedPaths));

    % Determine if selection is files or folders
    isFile = cellfun(@(p) isfile(p), selectedPaths);
    isFolder = cellfun(@(p) isfolder(p), selectedPaths);

    if isempty(selectedPaths)
        error('No valid files or folders were selected.');
    elseif all(isFile) && ~any(isFolder)
        selectionType = 'files';
    elseif all(isFolder) && ~any(isFile)
        selectionType = 'folders';
    else
        error('Please select either all files or all folders, not a mix of both.');
    end
end
