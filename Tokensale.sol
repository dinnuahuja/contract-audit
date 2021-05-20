//SPDX-License-Identifier: Unlicense
pragma solidity ^0.6.12;

// 0xe836aA4610d4366636a5cB01707854ed6476E742 testnet

interface TokenInterface {
    // determinamos las funciones que necesitamos del ERC20. Tienen que ser iguales.
    function decimals() external view  returns(uint8);
    function balanceOf(address _address) external view returns(uint256);
    function transfer(address _to, uint256 _value) external returns (bool success);
}

  


contract TokenSale  {
    address owner;
    uint256 price = 1919248;       // 10**18/521037500 = 1.919.247,654919272;
    TokenInterface TokenContract; // Variable de la interface.
    uint256 public tokensSold; // Acumulativo de tokens vendidos.
    
    event Sold(address indexed buyer, uint256 amount);
    
    modifier onlyOwner() {
         require(msg.sender == owner, "Solo puede llamar el propietario");
        _;
    }
    
    constructor(address _addressContract) public {
        
        owner = msg.sender;
        
        // pásamos el contrato del token a nuestra variable interface
        TokenContract = TokenInterface(_addressContract);
    }
    
    
  //No importamos toda la libreria SafeMath porque solamente necesitamos la función multiplicación.
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }
  
    function priceinWeis() public view  returns (uint256) {
    return price;
  }
  
 
    function setPrice(uint256 _newprice) public onlyOwner() {
    price = _newprice;
  }
  
  
   function ETHBalance() public view onlyOwner() returns (uint256)  {
    return address(this).balance;
  }
  
   function TokenBalance() public view onlyOwner() returns (uint256)  {
    return TokenContract.balanceOf(address(this));
  }
  

   
  
    
  function buy(uint256 amount) public payable {
      
      require(msg.value == amount);
      
      require( mul(amount, price) <= 1 ether); 
        
        // calculo de los tokens que se van a mandar.
        uint256 tokens = mul(amount, price);
        
        // al llamar la funcion original de transferencia tenemos que indicar la cantidad con los ceros de los decimales.
        uint256 amountwithzeros = mul(tokens, uint256(10) ** TokenContract.decimals());
        
        // comprobamos que el contrato de venta tenga los tokens que se desean comprar.
        require(TokenContract.balanceOf(address(this)) >= amountwithzeros); //address(this) direccion de nuestro contrato
        
        // realizamos la transferencia con un require por mayor seguridad.
        require(TokenContract.transfer(msg.sender, amountwithzeros)); // introducimos la cantidad escalada.
        
         // sumamos la venta.
        tokensSold += tokens; // fíjese, que usamos la cantidad sin la suma de los ceros de los decimales.
        
        emit Sold(msg.sender, tokens);
        
    }
    
    
    // Funcion que liquida el contrato para que no se pueda vender mas.
    function endSold() public  onlyOwner() {
        
        // compensacion de saldos. 
        require(TokenContract.transfer(owner, TokenContract.balanceOf(address(this))));
        msg.sender.transfer(address(this).balance);
       
    }
    

}
