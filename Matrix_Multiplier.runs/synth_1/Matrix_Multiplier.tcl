# 
# Synthesis run script generated by Vivado
# 

proc create_report { reportName command } {
  set status "."
  append status $reportName ".fail"
  if { [file exists $status] } {
    eval file delete [glob $status]
  }
  send_msg_id runtcl-4 info "Executing : $command"
  set retval [eval catch { $command } msg]
  if { $retval != 0 } {
    set fp [open $status w]
    close $fp
    send_msg_id runtcl-5 warning "$msg"
  }
}
create_project -in_memory -part xc7z020clg484-1

set_param project.singleFileAddWarning.threshold 0
set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_property webtalk.parent_dir M:/VivadoProjects/Final_Project/Final_Project.cache/wt [current_project]
set_property parent.project_path M:/VivadoProjects/Final_Project/Final_Project.xpr [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language VHDL [current_project]
set_property board_part em.avnet.com:zed:part0:1.3 [current_project]
set_property ip_output_repo m:/VivadoProjects/Final_Project/Final_Project.cache/ip [current_project]
set_property ip_cache_permissions {read write} [current_project]
read_vhdl -library xil_defaultlib {
  M:/VivadoProjects/Final_Project/Final_Project.srcs/sources_1/new/Async_ROM_12x5.vhd
  M:/VivadoProjects/Final_Project/Final_Project.srcs/sources_1/new/Async_ROM_15x5.vhd
  M:/VivadoProjects/Final_Project/Final_Project.srcs/sources_1/imports/VivadoProjects/DigEng.vhd
  M:/VivadoProjects/Final_Project/Final_Project.srcs/sources_1/imports/VivadoProjects/Param_Counter.vhd
  M:/VivadoProjects/Final_Project/Final_Project.srcs/sources_1/new/Control.vhd
  M:/VivadoProjects/Final_Project/Final_Project.srcs/sources_1/new/Param_RAM.vhd
  M:/VivadoProjects/Final_Project/Final_Project.srcs/sources_1/new/Datapath.vhd
  M:/VivadoProjects/Final_Project/Final_Project.srcs/sources_1/imports/Lab3b-VHDL/Debouncer.vhd
  M:/VivadoProjects/Final_Project/Final_Project.srcs/sources_1/new/Matrix_Multiplier.vhd
}
# Mark all dcp files as not used in implementation to prevent them from being
# stitched into the results of this synthesis run. Any black boxes in the
# design are intentionally left as such for best results. Dcp files will be
# stitched into the design at a later time, either when this synthesis run is
# opened, or when it is stitched into a dependent implementation run.
foreach dcp [get_files -quiet -all -filter file_type=="Design\ Checkpoint"] {
  set_property used_in_implementation false $dcp
}

synth_design -top Matrix_Multiplier -part xc7z020clg484-1


# disable binary constraint mode for synth run checkpoints
set_param constraints.enableBinaryConstraints false
write_checkpoint -force -noxdef Matrix_Multiplier.dcp
create_report "synth_1_synth_report_utilization_0" "report_utilization -file Matrix_Multiplier_utilization_synth.rpt -pb Matrix_Multiplier_utilization_synth.pb"
