
################################################################
# This is a generated script based on design: r8
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2024.2
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   if { [string compare $scripts_vivado_version $current_vivado_version] > 0 } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2042 -severity "ERROR" " This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Sourcing the script failed since it was created with a future version of Vivado."}

   } else {
     catch {common::send_gid_msg -ssname BD::TCL -id 2041 -severity "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   }

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source r8_script.tcl

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xc7z020clg400-1
   set_property BOARD_PART digilentinc.com:arty-z7-20:part0:1.1 [current_project]
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name r8

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_gid_msg -ssname BD::TCL -id 2001 -severity "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_gid_msg -ssname BD::TCL -id 2002 -severity "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_gid_msg -ssname BD::TCL -id 2003 -severity "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_gid_msg -ssname BD::TCL -id 2004 -severity "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_gid_msg -ssname BD::TCL -id 2005 -severity "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_gid_msg -ssname BD::TCL -id 2006 -severity "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
xilinx.com:ip:axi_dma:7.1\
xilinx.com:ip:smartconnect:1.0\
xilinx.com:ip:proc_sys_reset:5.0\
xilinx.com:ip:xlconcat:2.1\
xilinx.com:MNSIT_DNN_Digit_Recognition:DNN_Digit_Recog_Sig8:1.0\
"

   set list_ips_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2011 -severity "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2012 -severity "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

if { $bCheckIPsPassed != 1 } {
  common::send_gid_msg -ssname BD::TCL -id 2023 -severity "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set M_AXI_MM2S [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 -portmaps { \
   ARADDR { physical_name M_AXI_MM2S_araddr direction O left 31 right 0 } \
   ARBURST { physical_name M_AXI_MM2S_arburst direction O left 1 right 0 } \
   ARCACHE { physical_name M_AXI_MM2S_arcache direction O left 3 right 0 } \
   ARLEN { physical_name M_AXI_MM2S_arlen direction O left 7 right 0 } \
   ARPROT { physical_name M_AXI_MM2S_arprot direction O left 2 right 0 } \
   ARREADY { physical_name M_AXI_MM2S_arready direction I } \
   ARSIZE { physical_name M_AXI_MM2S_arsize direction O left 2 right 0 } \
   ARVALID { physical_name M_AXI_MM2S_arvalid direction O } \
   RDATA { physical_name M_AXI_MM2S_rdata direction I left 31 right 0 } \
   RLAST { physical_name M_AXI_MM2S_rlast direction I } \
   RREADY { physical_name M_AXI_MM2S_rready direction O } \
   RRESP { physical_name M_AXI_MM2S_rresp direction I left 1 right 0 } \
   RVALID { physical_name M_AXI_MM2S_rvalid direction I } \
   } \
  M_AXI_MM2S ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {32} \
   CONFIG.ARUSER_WIDTH {0} \
   CONFIG.AWUSER_WIDTH {0} \
   CONFIG.BUSER_WIDTH {0} \
   CONFIG.DATA_WIDTH {32} \
   CONFIG.FREQ_HZ {125000000} \
   CONFIG.HAS_BRESP {0} \
   CONFIG.HAS_BURST {0} \
   CONFIG.HAS_CACHE {1} \
   CONFIG.HAS_LOCK {0} \
   CONFIG.HAS_PROT {1} \
   CONFIG.HAS_QOS {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.HAS_RRESP {1} \
   CONFIG.HAS_WSTRB {0} \
   CONFIG.ID_WIDTH {0} \
   CONFIG.INSERT_VIP {0} \
   CONFIG.MAX_BURST_LENGTH {16} \
   CONFIG.NUM_READ_OUTSTANDING {16} \
   CONFIG.NUM_READ_THREADS {1} \
   CONFIG.NUM_WRITE_OUTSTANDING {2} \
   CONFIG.NUM_WRITE_THREADS {1} \
   CONFIG.PHASE {0.0} \
   CONFIG.PROTOCOL {AXI4} \
   CONFIG.READ_WRITE_MODE {READ_ONLY} \
   CONFIG.RUSER_BITS_PER_BYTE {0} \
   CONFIG.RUSER_WIDTH {0} \
   CONFIG.SUPPORTS_NARROW_BURST {0} \
   CONFIG.WUSER_BITS_PER_BYTE {0} \
   CONFIG.WUSER_WIDTH {0} \
   ] $M_AXI_MM2S
  set_property HDL_ATTRIBUTE.LOCKED {TRUE} [get_bd_intf_ports M_AXI_MM2S]

  set S00_AXI [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 -portmaps { \
   ARADDR { physical_name S00_AXI_araddr direction I left 31 right 0 } \
   ARBURST { physical_name S00_AXI_arburst direction I left 1 right 0 } \
   ARCACHE { physical_name S00_AXI_arcache direction I left 3 right 0 } \
   ARID { physical_name S00_AXI_arid direction I left 11 right 0 } \
   ARLEN { physical_name S00_AXI_arlen direction I left 3 right 0 } \
   ARLOCK { physical_name S00_AXI_arlock direction I left 1 right 0 } \
   ARPROT { physical_name S00_AXI_arprot direction I left 2 right 0 } \
   ARQOS { physical_name S00_AXI_arqos direction I left 3 right 0 } \
   ARREADY { physical_name S00_AXI_arready direction O } \
   ARSIZE { physical_name S00_AXI_arsize direction I left 2 right 0 } \
   ARVALID { physical_name S00_AXI_arvalid direction I } \
   AWADDR { physical_name S00_AXI_awaddr direction I left 31 right 0 } \
   AWBURST { physical_name S00_AXI_awburst direction I left 1 right 0 } \
   AWCACHE { physical_name S00_AXI_awcache direction I left 3 right 0 } \
   AWID { physical_name S00_AXI_awid direction I left 11 right 0 } \
   AWLEN { physical_name S00_AXI_awlen direction I left 3 right 0 } \
   AWLOCK { physical_name S00_AXI_awlock direction I left 1 right 0 } \
   AWPROT { physical_name S00_AXI_awprot direction I left 2 right 0 } \
   AWQOS { physical_name S00_AXI_awqos direction I left 3 right 0 } \
   AWREADY { physical_name S00_AXI_awready direction O } \
   AWSIZE { physical_name S00_AXI_awsize direction I left 2 right 0 } \
   AWVALID { physical_name S00_AXI_awvalid direction I } \
   BID { physical_name S00_AXI_bid direction O left 11 right 0 } \
   BREADY { physical_name S00_AXI_bready direction I } \
   BRESP { physical_name S00_AXI_bresp direction O left 1 right 0 } \
   BVALID { physical_name S00_AXI_bvalid direction O } \
   RDATA { physical_name S00_AXI_rdata direction O left 31 right 0 } \
   RID { physical_name S00_AXI_rid direction O left 11 right 0 } \
   RLAST { physical_name S00_AXI_rlast direction O } \
   RREADY { physical_name S00_AXI_rready direction I } \
   RRESP { physical_name S00_AXI_rresp direction O left 1 right 0 } \
   RVALID { physical_name S00_AXI_rvalid direction O } \
   WDATA { physical_name S00_AXI_wdata direction I left 31 right 0 } \
   WID { physical_name S00_AXI_wid direction I left 11 right 0 } \
   WLAST { physical_name S00_AXI_wlast direction I } \
   WREADY { physical_name S00_AXI_wready direction O } \
   WSTRB { physical_name S00_AXI_wstrb direction I left 3 right 0 } \
   WVALID { physical_name S00_AXI_wvalid direction I } \
   } \
  S00_AXI ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {32} \
   CONFIG.ARUSER_WIDTH {0} \
   CONFIG.AWUSER_WIDTH {0} \
   CONFIG.BUSER_WIDTH {0} \
   CONFIG.DATA_WIDTH {32} \
   CONFIG.FREQ_HZ {125000000} \
   CONFIG.HAS_BRESP {1} \
   CONFIG.HAS_BURST {1} \
   CONFIG.HAS_CACHE {1} \
   CONFIG.HAS_LOCK {1} \
   CONFIG.HAS_PROT {1} \
   CONFIG.HAS_QOS {1} \
   CONFIG.HAS_REGION {0} \
   CONFIG.HAS_RRESP {1} \
   CONFIG.HAS_WSTRB {1} \
   CONFIG.ID_WIDTH {12} \
   CONFIG.INSERT_VIP {0} \
   CONFIG.MAX_BURST_LENGTH {16} \
   CONFIG.NUM_READ_OUTSTANDING {8} \
   CONFIG.NUM_READ_THREADS {4} \
   CONFIG.NUM_WRITE_OUTSTANDING {8} \
   CONFIG.NUM_WRITE_THREADS {4} \
   CONFIG.PHASE {0.0} \
   CONFIG.PROTOCOL {AXI3} \
   CONFIG.READ_WRITE_MODE {READ_WRITE} \
   CONFIG.RUSER_BITS_PER_BYTE {0} \
   CONFIG.RUSER_WIDTH {0} \
   CONFIG.SUPPORTS_NARROW_BURST {0} \
   CONFIG.WUSER_BITS_PER_BYTE {0} \
   CONFIG.WUSER_WIDTH {0} \
   ] $S00_AXI
  set_property HDL_ATTRIBUTE.LOCKED {TRUE} [get_bd_intf_ports S00_AXI]


  # Create ports
  set dout [ create_bd_port -dir O -from 1 -to 0 dout ]
  set_property -dict [ list \
   CONFIG.PortType {intr} \
   CONFIG.PortWidth {2} \
   CONFIG.SENSITIVITY {NULL:LEVEL_HIGH} \
 ] $dout
  set ext_reset_in [ create_bd_port -dir I -type rst ext_reset_in ]
  set_property -dict [ list \
   CONFIG.INSERT_VIP {0} \
   CONFIG.POLARITY {ACTIVE_LOW} \
 ] $ext_reset_in
  set peripheral_aresetn [ create_bd_port -dir O -from 0 -to 0 -type rst peripheral_aresetn ]
  set_property -dict [ list \
   CONFIG.INSERT_VIP {0} \
   CONFIG.POLARITY {ACTIVE_LOW} \
 ] $peripheral_aresetn
  set s_axi_lite_aclk [ create_bd_port -dir I -type clk -freq_hz 125000000 s_axi_lite_aclk ]
  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {M_AXI_MM2S:S00_AXI} \
   CONFIG.ASSOCIATED_CLKEN {s_sc_aclken} \
   CONFIG.ASSOCIATED_RESET {peripheral_aresetn} \
   CONFIG.CLK_DOMAIN {DigitDNN_processing_system7_0_0_FCLK_CLK0} \
   CONFIG.FREQ_TOLERANCE_HZ {0} \
   CONFIG.INSERT_VIP {0} \
   CONFIG.PHASE {0.0} \
 ] $s_axi_lite_aclk

  # Create instance: axi_dma_0, and set properties
  set axi_dma_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma:7.1 axi_dma_0 ]
  set_property -dict [list \
    CONFIG.c_include_mm2s_dre {1} \
    CONFIG.c_include_s2mm {0} \
    CONFIG.c_include_sg {0} \
    CONFIG.c_m_axis_mm2s_tdata_width {16} \
  ] $axi_dma_0


  # Create instance: axi_smc, and set properties
  set axi_smc [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 axi_smc ]
  set_property -dict [list \
    CONFIG.NUM_MI {2} \
    CONFIG.NUM_SI {1} \
  ] $axi_smc


  # Create instance: rst_ps7_0_125M, and set properties
  set rst_ps7_0_125M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_ps7_0_125M ]

  # Create instance: xlconcat_0, and set properties
  set xlconcat_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_0 ]

  # Create instance: DNN_Digit_Recog_Sig8_0, and set properties
  set DNN_Digit_Recog_Sig8_0 [ create_bd_cell -type ip -vlnv xilinx.com:MNSIT_DNN_Digit_Recognition:DNN_Digit_Recog_Sig8:1.0 DNN_Digit_Recog_Sig8_0 ]

  # Create interface connections
  connect_bd_intf_net -intf_net axi_dma_0_M_AXIS_MM2S [get_bd_intf_pins DNN_Digit_Recog_Sig8_0/S00_AXIS] [get_bd_intf_pins axi_dma_0/M_AXIS_MM2S]
  connect_bd_intf_net -intf_net axi_dma_0_M_AXI_MM2S [get_bd_intf_pins axi_dma_0/M_AXI_MM2S] [get_bd_intf_ports M_AXI_MM2S]
  connect_bd_intf_net -intf_net axi_smc_M00_AXI [get_bd_intf_pins axi_smc/M00_AXI] [get_bd_intf_pins axi_dma_0/S_AXI_LITE]
  connect_bd_intf_net -intf_net axi_smc_M01_AXI [get_bd_intf_pins axi_smc/M01_AXI] [get_bd_intf_pins DNN_Digit_Recog_Sig8_0/S00_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_M_AXI_GP0 [get_bd_intf_pins axi_smc/S00_AXI] [get_bd_intf_ports S00_AXI]

  # Create port connections
  connect_bd_net -net axi_dma_0_mm2s_introut  [get_bd_pins axi_dma_0/mm2s_introut] \
  [get_bd_pins xlconcat_0/In0]
  connect_bd_net -net processing_system7_0_FCLK_CLK0  [get_bd_ports s_axi_lite_aclk] \
  [get_bd_pins axi_dma_0/s_axi_lite_aclk] \
  [get_bd_pins rst_ps7_0_125M/slowest_sync_clk] \
  [get_bd_pins axi_dma_0/m_axi_mm2s_aclk] \
  [get_bd_pins axi_smc/aclk] \
  [get_bd_pins DNN_Digit_Recog_Sig8_0/s00_axi_aclk] \
  [get_bd_pins DNN_Digit_Recog_Sig8_0/s00_axis_aclk]
  connect_bd_net -net processing_system7_0_FCLK_RESET0_N  [get_bd_ports ext_reset_in] \
  [get_bd_pins rst_ps7_0_125M/ext_reset_in]
  connect_bd_net -net rst_ps7_0_125M_peripheral_aresetn  [get_bd_pins rst_ps7_0_125M/peripheral_aresetn] \
  [get_bd_pins axi_dma_0/axi_resetn] \
  [get_bd_pins axi_smc/aresetn] \
  [get_bd_ports peripheral_aresetn] \
  [get_bd_pins DNN_Digit_Recog_Sig8_0/s00_axi_aresetn] \
  [get_bd_pins DNN_Digit_Recog_Sig8_0/s00_axis_aresetn]
  connect_bd_net -net xlconcat_0_dout  [get_bd_pins xlconcat_0/dout] \
  [get_bd_ports dout]

  # Create address segments
  assign_bd_address -offset 0x00000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces axi_dma_0/Data_MM2S] [get_bd_addr_segs M_AXI_MM2S/Reg] -force
  assign_bd_address -offset 0x40000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces S00_AXI] [get_bd_addr_segs DNN_Digit_Recog_Sig8_0/S00_AXI/S00_AXI_reg] -force
  assign_bd_address -offset 0x40010000 -range 0x00010000 -target_address_space [get_bd_addr_spaces S00_AXI] [get_bd_addr_segs axi_dma_0/S_AXI_LITE/Reg] -force


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


