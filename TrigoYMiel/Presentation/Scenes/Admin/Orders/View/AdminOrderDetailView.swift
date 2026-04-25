//
//  AdminOrderDetailView.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//
import SwiftUI

struct AdminOrderDetailView: View {
    
    @Binding var order: Order
    let isUpdating: Bool
    let onUpdate:   (OrderStatus) -> Void
    @Environment(\.dismiss) private var dismiss
 
    @State private var showCancelAlert = false
    
    var body: some View {
        ZStack {
            Color("ColorBackground").ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // MARK: Header con flecha
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.title3.bold())
                                .foregroundColor(Color("ColorPrimary"))
                        }

                        Text("Detalle de pedido")
                            .font(.title3.bold())
                            .foregroundColor(Color("ColorPrimary"))
                            .padding(.leading, 8)

                        Spacer()

                   
                        if order.status != .delivered && order.status != .cancelled {
                            Button("Cancelar pedido") {
                                showCancelAlert = true
                            }
                            .font(.caption.bold())
                            .foregroundColor(.red)
                        }
                    }
                    .padding(.top, 8)
                     
                    // MARK: ID + Cliente
                    VStack(alignment: .leading, spacing: 6) {
                        Text("ID: \(order.displayId)")
                            .font(.title2.bold())
                            .foregroundColor(Color("ColorPrimary"))
                        Text(order.additionalNotes.isEmpty ? "Sin notas" : order.additionalNotes)
                            .font(.caption)
                            .foregroundColor(Color("ColorPrimary").opacity(0.5))
                    }
                    .padding(.top, 8)
                    
                    // MARK: Productos
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Productos")
                            .font(.headline.bold())
                            .foregroundColor(Color("ColorPrimary"))
                        
                        VStack(spacing: 10) {
                            ForEach(order.items) { item in
                                HStack(alignment: .top) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(item.nameSnap)
                                            .font(.subheadline.bold())
                                            .foregroundColor(Color("ColorPrimary"))
                                        Text("Unidades: \(item.quantity)")
                                            .font(.caption)
                                            .foregroundColor(Color("ColorPrimary").opacity(0.6))
                                        Text("Subtotal: \(item.formattedSubtotal)")
                                            .font(.caption)
                                            .foregroundColor(Color("ColorPrimary").opacity(0.6))
                                    }
                                    Spacer()
                                }
                                .padding(12)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                        
                  
                        HStack {
                            Spacer()
                            Text("Total: \(order.formattedTotal)")
                                .font(.title3.bold())
                                .foregroundColor(Color("ColorPrimary"))
                        }
                        .padding(.top, 4)
                    }
                    
                    Divider()
                        .overlay(Color("ColorPrimary").opacity(0.15))
                    
               
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Estado del pedido")
                            .font(.headline.bold())
                            .foregroundColor(Color("ColorPrimary"))

                        OrderStatusPickerView(currentStatus: order.status)  
                    }
                    
                    // MARK: Sección Inferior Dinámica
                    if order.status == .cancelled {
                 
                        statusFinalView(text: "Pedido cancelado", icon: "xmark.circle.fill", color: .red)
                        
                    } else if let nextStatus = order.status.next {
                      
                        Button {
                            onUpdate(nextStatus)
                        } label: {
                            Group {
                                if isUpdating {
                                    ProgressView().tint(.white)
                                } else {
                                    Text("Avanzar a \(nextStatus.displayName)")
                                        .font(.subheadline.bold())
                                        .foregroundColor(.white)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                        }
                        .background(RoundedRectangle(cornerRadius: 14).fill(Color("ColorSecondary")))
                        .disabled(isUpdating)
                        
                    } else {
                   
                        statusFinalView(text: "Pedido entregado", icon: "checkmark.seal.fill", color: Color("ColorSecondary"))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
        }
        .navigationTitle("Detalle de pedido")
        .navigationBarTitleDisplayMode(.inline)
        // MARK: Botón Cancelar (Arriba a la izquierda)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if order.status != .delivered && order.status != .cancelled {
                    Button("Cancelar") {
                        showCancelAlert = true
                    }
                    .foregroundColor(.red)
                    .font(.subheadline.bold())
                }
            }
        }
        .navigationBarHidden(true)
        .alert("¿Cancelar pedido?", isPresented: $showCancelAlert) {
            Button("No", role: .cancel) { }
            Button("Sí, cancelar", role: .destructive) {
                onUpdate(.cancelled)
            }
        } message: {
            Text("Esta acción no se puede deshacer.")
        }
    }
    
   
    @ViewBuilder
    private func statusFinalView(text: String, icon: String, color: Color) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
            Text(text)
                .font(.subheadline.bold())
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 52)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(color.opacity(0.12))
        )
    }
}

