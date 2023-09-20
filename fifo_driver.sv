class fifo_driver extends uvm_driver#(fifo_seq_item);
  virtual fifo_interface vif;
  fifo_seq_item req;
  `uvm_component_utils(fifo_driver)
  
  function new(string name = "fifo_driver", uvm_component parent);
    super.new(name, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual fifo_interface)::get(this, "", "vif", vif))
      `uvm_fatal("Driver: ", "No vif is found!")
  endfunction

  virtual task run_phase(uvm_phase phase);
    if(vif. rstn==0)begin
    vif.dr_mp.dr_cb. i_wren <= 'b0;
    vif.dr_mp.dr_cb.i_rden<= 'b0;
    vif.dr_mp.dr_cb.i_wrdata<= 'b0;
     // vif.dr_mp.dr_cb.o_full<= 'b0; 
     //  vif.dr_mp.dr_cb.o_empty<= 'b0;
    end
    forever begin
      seq_item_port.get_next_item(req);
      if(req.i_wren == 1)
        main_write(req.i_wrdata);
      else if(req.i_rden== 1)
        main_read();
      seq_item_port.item_done();
    end
  endtask
  
    virtual task main_write(input [127:0] din);
    @(posedge vif.dr_mp.clk)
    vif.dr_mp.dr_cb.i_wren <= 'b1;
    vif.dr_mp.dr_cb.i_wrdata <= din;
    @(posedge vif.dr_mp.clk)
    vif.dr_mp.dr_cb.i_wren<= 'b0;
  endtask
  
  virtual task main_read();
    @(posedge vif.dr_mp.clk)
    vif.dr_mp.dr_cb.i_rden <= 'b1;
    @(posedge vif.dr_mp.clk)
    vif.dr_mp.dr_cb.i_rden <= 'b0;
  endtask

endclass